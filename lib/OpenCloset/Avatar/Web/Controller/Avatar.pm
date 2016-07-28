package OpenCloset::Avatar::Web::Controller::Avatar;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Types;

use Digest::MD5 ();
use HTTP::Tiny;
use Image::Info ();
use Image::Imlib2;
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
        my $avatar_image = $avatar->avatar_images( undef, { order_by => { -desc => 'rating' }, rows => 1 } )->single;
        my ( $prefix, $rest ) = $md5sum =~ /(\w{2})(\w*)/;
        $image = Path::Tiny::path(
            $self->app->home->rel_file( sprintf( 'public/thumbnails/%s/%s.%d', $prefix, $rest, $avatar_image->id ) ) );
        $image->touchpath && $image->spew_raw( $avatar_image->image ) unless $image->exists;
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
        my $avatar_image = $avatar->avatar_images( undef, { order_by => { -desc => 'rating' }, rows => 1 } )->single;
        $image = Path::Tiny::path(
            $self->app->home->rel_file( sprintf( 'public/thumbnails/%s/%s.%d', $prefix, $rest, $avatar_image->id ) ) );
        $image->touchpath && $image->spew_raw( $avatar_image->image ) unless $image->exists;
    }

    if ($s) {
        my $resize = Path::Tiny::path( sprintf '%s.s=%dx%d', $image, $s, $s );
        unless ( $resize->exists ) {
            my $im = Image::Imlib2->load("$image");
            my $image2 = $im->create_scaled_image( $s, $s );
            $image2->image_set_format('png');
            $image2->save("$resize");
        }

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

=head2 images

    # avatar.images
    GET /avatar/:md5sum/images

    ["http:\/\/localhost:5000\/avatar\/c21f969b5f03d33d43e04f8f136e7682\/images\/1","http:\/\/localhost:5000\/avatar\/c21f969b5f03d33d43e04f8f136e7682\/images\/2"]

=cut

sub images {
    my $self   = shift;
    my $md5sum = $self->param('md5sum');

    my $avatar = $self->schema->resultset('Avatar')->find( { md5sum => $md5sum } );
    return $self->error( 404, "Not found images: $md5sum" ) unless $avatar;

    my $images = $avatar->avatar_images( undef, { columns => [qw/id/], order_by => { -desc => 'rating' } } );
    my @url;

    while ( my $avatar_image = $images->next ) {
        push @url, $self->url_for( 'avatar.image', md5sum => $avatar->md5sum, image_id => $avatar_image->id )->to_abs;
    }

    $self->render( json => \@url );
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

    my $avatar = $self->schema->resultset('Avatar')->find_or_create( { md5sum => Digest::MD5::md5_hex($key) } );

    return $self->error( 500, 'Failed to create a avatar' ) unless $avatar;

    my $avatar_image = $avatar->create_related( 'avatar_images', { image => $img->slurp } );

    return $self->error( 500, 'Failed to create a avatar image' ) unless $avatar_image;

    $self->res->headers->location(
        $self->url_for(
            'avatar.image',
            md5sum   => $avatar->md5sum,
            image_id => $avatar_image->id
        )
    );

    $self->render(
        json => {
            id           => $avatar->id,
            md5sum       => $avatar->md5sum,
            create_date  => $avatar->create_date,
            avatar_image => {
                id          => $avatar_image->id,
                rating      => $avatar_image->rating || '0',
                create_date => $avatar_image->create_date,
            }
        },
        status => 201
    );
}

1;
