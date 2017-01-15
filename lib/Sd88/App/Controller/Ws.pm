package Sd88::App::Controller::Ws;
#ABSTRACT: Actions for WebSocket worker

use Mojo::Base 'Mojolicious::Controller';

sub main { 
  my $c = shift;

# Opened
  $c->app->log->debug('WebSocket opened');
  $c->send("Welcome! Sd88 websockets commands:");
  # Increase inactivity timeout for connection a bit
  $c->inactivity_timeout(300);

  # Incoming message
  $c->on(message => sub {
    my ($c, $msg) = @_;
    $c->send("echo: $msg");
  });

  # Closed
  $c->on(finish => sub {
    my ($c, $code, $reason) = @_;
    $c->app->log->debug("WebSocket closed with status $code");
  });



  #my $id = $c->stash('id');
  #$c->render( json => { 
  #   msg     => "OK", 
  #   content => "Begin Ws working"
  #});
}

1;
