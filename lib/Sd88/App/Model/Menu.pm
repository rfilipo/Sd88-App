package Sd88::App::Model::Menu;
#ABSTRACT: Model for Menu objects, they have a handle id, and a hash ref of title => url link

use strict;
use warnings;

my $MENU = {
  'public' => {
    'home' => '/',
    'about' => '/content/0',
    'login' => '/login'
   },
  'private' => {
    'home' => '/',
    'about' => '/content/0',
    'logout' => '/logout',
    'profile' => '/profile'
   }
};

sub new { bless {}, shift }

sub get_menu {
  my ($self, $id) = @_;
  return $MENU->{$id};
}

1;

