package Sd88::App::Controller::Api;
#ABSTRACT: Actions for API Endpoints

use Mojo::Base 'Mojolicious::Controller';

sub auth { 
  my $c = shift;
  $c->render( json => { 
     msg=>"test", 
     auth=>"123" 
  });
  
  use Data::Dumper;
  print Dumper $c->users;

}

sub menu { 
  my $c = shift;
  $c->render( json => { 
     msg  => "OK", 
     menu => $c->menus->get_menu,
  });
}

sub content { 
  my $c = shift;
  my $id = $c->stash('id');
  $c->render( json => { 
     msg     => "OK", 
     content => $c->contents->get_content($id)
  });
}

1;
