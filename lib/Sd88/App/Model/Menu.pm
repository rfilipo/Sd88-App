package Sd88::App::Model::Menu;
#ABSTRACT: Model for Menu objects, they have a handle id, and a hash ref of title => url link

use strict;
use warnings;

my $MENU = {
  'public' => {
    '0' => {'home' => '/'},
    '1' => {'about' => '/content/1'},
    '2' => {'register' => '/register'},
    '3' => {'login' => '/login'}
   },
  'private' => {
    'home' => '/',
    'about' => '/content/1',
    'logout' => '/logout',
    'profile' => '/profile'
   }
};

sub new { bless {}, shift }

sub get_menu {
  my ($self, $id) = @_;
  print "Getting menu $id ...\n";
  use Data::Dumper;
  print Dumper $MENU;
  return $MENU->{$id};
}

1;

