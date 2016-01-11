package OpenCloset::Avatar::Web;
use Mojo::Base 'Mojolicious';

use OpenCloset::Avatar::Schema;

use version; our $VERSION = qv("v0.0.1");

has schema => sub {
    my $self = shift;
    OpenCloset::Avatar::Schema->connect(
        {
            dsn      => $self->config->{database}{dsn},
            user     => $self->config->{database}{user},
            password => $self->config->{database}{pass},
            %{ $self->config->{database}{opts} },
        }
    );
};

=head1 METHODS

=head2 startup

This method will run once at server start

=cut

sub startup {
    my $self = shift;

    $self->plugin('Config');
    $self->plugin('OpenCloset::Plugin::Helpers');

    $self->secrets( [$ENV{OPENCLOSET_AVATAR_WEB_SECRET} || time] );
    $self->sessions->cookie_name( $self->app->moniker );
    $self->_routes;
}

=head2 _routes

Handle routing rules

=cut

sub _routes {
    my $self = shift;

    my $r = $self->routes;
    $r->get('/avatar/:md5sum')->to('avatar#md5sum')->name('avatar');
    $r->post('/avatar')->to('avatar#create')->name('avatar.create');
}

1;
