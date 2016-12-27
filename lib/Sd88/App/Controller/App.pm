package Sd88::App::Controller::App;
#ABSTRACT: Actions for the App endpoints

use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  $c->reply->static('index.html');
}
sub register {
  my $c = shift;
  $c->reply->static('register.html');
}
sub profile {
  my $c = shift;
  $c->reply->static('profile.html');
}
sub login {
  my $c = shift;
  $c->reply->static('login.html');
}
sub logout {
  my $c = shift;
  $c->reply->static('logout.html');
}
sub invite {
  my $c = shift;
  $c->reply->static('invite.html');
}
sub content {
  my $c = shift;
  $c->reply->static('content.html');
}
sub setup {
  my $c = shift;
  if (-e 'app.db') {
    # hmmm, do we really need a setup?     
  } 
}

1;
