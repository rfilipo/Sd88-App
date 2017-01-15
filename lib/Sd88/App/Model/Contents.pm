package Sd88::App::Model::Contents;
#ABSTRACT: Model for Content objects, they have id, content and price

#TODO: Link with sqlite

use strict;
use warnings;


my $CONTENTS = {
  0 => '<p>Studio Design 88 LLC.</p>',
  1 => '<div class="section">Creative and Custom Services.</div>',
  2 => '<h1>Login Form</h1>'
};

sub new { bless {}, shift }

sub get_content {
  my $c = shift;
  my $id = shift;
  print "Getting content $id ... \n";
  return $CONTENTS->{$id};
}

1;

