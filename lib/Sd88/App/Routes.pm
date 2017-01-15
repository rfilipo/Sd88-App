package Sd88::App::Routes;
#ABSTRACT: Where I'll go?

sub create_routes{
  my $r = shift;

  # APP
  $r->get( '/' )                 ->to( 'app#index');
  $r->get( '/login' )            ->to( 'app#login');
  $r->get( '/logout' )           ->to( 'app#logout');
  $r->get( '/profile/:id' )      ->to( 'app#profile');
  $r->get( '/register' )         ->to( 'app#register');
  $r->get( '/invite' )           ->to( 'app#invite');
  $r->get( '/content/:id' )      ->to( 'app#content');

  # API
  $r->get( '/api/auth' )         ->to( 'api#auth');
  $r->get( '/api/menu/:id' )     ->to( 'api#menu');
  $r->get( '/api/content/:id' )  ->to( 'api#content');
  $r->get( '/api/content/:id/edit')->to( 'api#edit_content');
  $r->get( '/api/user/:id'      )->to( 'api#user');
  $r->get( '/api/user/:id/edit' )->to( 'api#edit_user');
  $r->get( '/api/user/register' )->to( 'api#register_user');
  $r->get( '/api/user/invite' )  ->to( 'api#invite');

  #$r->websocket( 'ws' )->to( 'ws#main');
}

1;
