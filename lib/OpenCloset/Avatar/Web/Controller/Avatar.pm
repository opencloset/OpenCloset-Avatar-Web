package OpenCloset::Avatar::Web::Controller::Avatar;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Types;

use Digest::MD5 ();
use HTTP::Tiny;
use Image::Info ();
use Image::Resize;
use Path::Tiny ();

has schema => sub { shift->app->schema };

=encoding utf8

=head1 METHODS

=head2 md5sum

    # avatar
    GET /avatar/:md5sum

    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?s=200
    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?d=http://www.example.com/default.jpg
    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?s=200&d=http://www.example.com/default.jpg

=head3 params

=over

=item d

default image file URL

=item s

image C<width x height> size

C<200 x 200> if C<s> is 200

=back

=cut

sub md5sum {
    my $self   = shift;
    my $md5sum = $self->param('md5sum');

    my $v = $self->validation;
    $v->optional('d');
    $v->optional('s')->like(qr/^[0-9]+$/);

    return $self->error( 400, 'Failed to validation: ' . join( ', ', @{ $v->failed } ) ) if $v->has_error;

    my $d = $v->param('d');
    my $s = $v->param('s');

    my $avatar = $self->schema->resultset('Avatar')->find( { md5sum => $md5sum } );
    my $image;
    if ($avatar) {
        my ( $prefix, $rest ) = $md5sum =~ /(\w{2})(\w*)/;
        $image = Path::Tiny::path( $self->app->home->rel_file("public/thumbnails/$prefix/$rest") );
        $image->touchpath && $image->spew_raw( $avatar->image ) unless $image->exists;
    }
    else {
        if ( $d && $d =~ /^http/ ) {
            my $md5sum = Digest::MD5::md5_hex($d);
            my ( $prefix, $rest ) = $md5sum =~ /(\w{2})(\w*)/;
            $image = Path::Tiny::path( $self->app->home->rel_file("public/thumbnails/$prefix/$rest") );
            unless ( $image->exists ) {
                my $res = HTTP::Tiny->new( timeout => 1 )->get($d);
                if ( $res->{success} && $res->{headers}{'content-type'} =~ /image/ ) {
                    $image->touchpath;
                    $image->spew_raw( $res->{content} );
                }
                else {
                    $image = undef;
                }
            }
        }
    }

    unless ($image) {
        my $md5sum = Digest::MD5::md5_hex('default');
        my ( $prefix, $rest ) = $md5sum =~ /(\w{2})(\w*)/;
        my $avatar = $self->schema->resultset('Avatar')->find( { md5sum => $md5sum } );
        $image = Path::Tiny::path( $self->app->home->rel_file("public/thumbnails/$prefix/$rest") );
        $image->touchpath && $image->spew_raw( $avatar->image ) unless $image->exists;
    }

    if ($s) {
        my $ir     = Image::Resize->new("$image");
        my $gd     = $ir->resize( $s, $s );
        my $resize = Path::Tiny::path( sprintf '%ss=%dx%d', $image, $s, $s );
        $resize->spew_raw( $gd->png ) unless $resize->exists;
        $image = $resize;
    }

    my $parent = $image->parent;
    my $types  = Mojolicious::Types->new;
    my $type   = Image::Info::image_type("$image");

    return $self->error( 400, "Not supported image: $type->{error}" ) if $type->{error};

    my $mime_type = $types->type( lc $type->{file_type} );

    return $self->error( 400, "Not supported image type: $type->{file_type}" ) unless $mime_type;

    $self->res->headers->content_type($mime_type);
    return $self->reply->static( sprintf "thumbnails/%s/%s", $parent->basename, $image->basename );
}

=head2 create

    # avatar.create
    POST /avatar

=head3 params

=over

=item token

Authenticate via pre-defined C<token>, disallow not authentication requests

    token=s3cr3t

=item key

any strings

    key=abc@example.com

=item img

image raw data

    <raw data of a.png>

=back

=cut

sub create {
    my $self = shift;

    my $v = $self->validation;

    my @tokens = ( $self->config->{token} );
    $v->required('token')->in(@tokens);
    $v->required('key');
    $v->required('img');

    return $self->error( 400, 'Failed to validation: ' . join( ', ', @{ $v->failed } ) ) if $v->has_error;

    my $key = $v->param('key');
    my $img = $v->param('img');

    my $avatar = $self->schema->resultset('Avatar')
        ->update_or_create( { md5sum => Digest::MD5::md5_hex($key), image => $img->slurp } );

    return $self->error( 500, 'Failed to create avatar' ) unless $avatar;

    ## image 가 등록/변경되고 나면 관련된 thumbnails 를 지운다
    my ( $prefix, $rest ) = $avatar->md5sum =~ /(\w{2})(\w*)/;
    my $dir = Path::Tiny::path( $self->app->home->rel_dir("public/thumbnails/$prefix") );
    for my $file ( $dir->children ) {
        $file->remove if $file->basename =~ /$rest/;
    }

    $self->res->headers->location( $self->url_for( 'avatar', md5sum => $avatar->md5sum ) );
    $self->render(
        json => {
            id          => $avatar->id,
            md5sum      => $avatar->md5sum,
            create_date => $avatar->create_date,
            update_date => $avatar->update_date
        },
        status => 201
    );
}

1;
