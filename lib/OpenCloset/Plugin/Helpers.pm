package OpenCloset::Plugin::Helpers;

use Mojo::Base 'Mojolicious::Plugin';

=encoding utf8

=head1 NAME

OpenCloset::Plugin::Helpers

=head1 SYNOPSIS

    # Mojolicious::Lite
    plugin 'Evid::Plugin::Helpers';
    # Mojolicious
    $self->plugin('OpenCloset::Plugin::Helpers');

=head1 HELPERS

=cut

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->helper( log => sub { shift->app->log } );
    $app->helper( error => \&error );
}

=head2 error( $status, $error )

    get '/foo' => sub {
        my $self = shift;
        my $required = $self->param('something');
        return $self->error(400, 'oops wat the..') unless $required;
    } => 'foo';

=head2 log

shortcut for C<$self-E<gt>app-E<gt>log>

    $self->app->log->debug('message');    # OK
    $self->log->debug('message');         # OK, shortcut

=cut

sub error {
    my ( $self, $status, $error ) = @_;

    $self->log->error($error);
    $self->render( json => { json => { error => $error || q{} } }, status => $status );

    return;
}

1;
