package Sd88::App::Model::Contents;
#ABSTRACT: Model for Content objects, they have id, content and price

use strict;
use warnings;


my $CONTENTS = {
  0 => '<p>some text about me</p>',
  1 => '<div class="section">its a section</div>',
  2 => 'raw text'
};

sub new { bless {}, shift }

sub get_content {
  my ($self, $id) = @_;
  return $CONTENTS->{$id};
}

1;

