use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

$ENV{MOJO_CONFIG} //= 'avatar.conf';

my $t = Test::Mojo->new('OpenCloset::Avatar::Web');
$t->get_ok('/avatar/123')->status_is(200)->content_type_like(qr/image/);

done_testing();
