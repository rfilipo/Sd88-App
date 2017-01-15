sub {
  my $c = shift;
  my $data = shift;
  my $d = $data->data;

use Mojo::Log;
use Data::Dumper;
#print Dumper $c->app;
my $log = Mojo::Log->new;
$log->debug("Registering new user:\n");
#print Dumper $data->data; 

  my $response;
  eval {
  $response = $c->app->users->create (
    email => $d->{email},
    password => $d->{password},
    credits => 100
  )}; if ($@ || $response =~ /UNIQUE constraint failed/ ) 
  { print "Error!!!\n"; use Data::Dumper; print Dumper $@;
    $d->{error} = $response;
  }
  $d->{auth_key} = $response;
  delete $d->{password};
  delete $d->{type};
  delete $d->{msg};
  delete $d->{cmd};
  # authenticate user
$log->debug("Authenticating user:\n");
  my $auth;
  eval {
  $auth = $c->app->auth->create (
    email => $d->{email},
    auth_key => $d->{auth_key}
  )}; if ( $@ ) 
  { print "Error!!!\n"; use Data::Dumper; print Dumper $@;
    $d->{error} .= $response;
  }

  $data->reply($d);
  return 1;
}
