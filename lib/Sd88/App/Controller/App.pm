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
  my $id = $c->param('id');
  $c->stash( title  => "User profile - $id");
  $c->users->read( id => $id );
  $c->stash( user  => $c->users);
  $c->render(template => 'user/profile');
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
  my $id = $c->param('id');
  $c->stash( title  => $id);
  my $content = $c->contents->get_content( $id );
use Data::Dumper;
print Dumper $content;
  $c->stash( content  => $content);
  $c->render(template => 'content/main');
}
sub setup {
  my $c = shift;
  if (-e 'app.db') {
    # hmmm, do we really need a setup?     
  } 
}

1;
