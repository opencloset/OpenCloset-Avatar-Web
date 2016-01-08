package OpenCloset::Avatar::Web::Controller::Avatar;
use Mojo::Base 'Mojolicious::Controller';

=head1 METHODS

=head2 md5sum

    # avatar
    GET /avatar/:md5sum

    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?s=200
    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?d=http://www.example.com/default.jpg
    GET /avatar/d41d8cd98f00b204e9800998ecf8427e?s=200&d=http://www.example.com/default.jpg

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

    my $d = $self->param('d');
    my $s = $self->param('s');
    return $self->redirect_to($d) if $d;

    # http://www.example.com/default.jpg 의 md5sum 으로 찾아보고 없으면 fetch 해서 처리
}

=head2 create

    # avatar.create
    POST /avatar

=over

=item key

=item img

=back

=cut

sub create {
    my $self = shift;
}

1;
