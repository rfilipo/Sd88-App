use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sd88::App');
$t->get_ok('/')->status_is(200)->content_like(qr/Monsenhor/i);

done_testing();
