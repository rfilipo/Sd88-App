package Sd88::App::Model::Users;
#ABSTRACT: Model for Users objects, they have id, email, password and credits
#use base Sd88::App::Model;
#use Mojo::Base 'Sd88::App::Model';
use Mojo::Util qw(secure_compare);
use Mojo::Util qw(sha1_sum);
use DBI;
my $counter;

sub new { 
  my $self=shift; 
  bless {
    db => shift
  }, $self;
}

sub hashfy {
	my $self	= shift;
        my $password    = shift;
	return sha1_sum join " ", localtime time, $counter++, $password;
}



sub generate_token {
	my $self	= shift;
	return sha1_sum join " ", localtime time, $self, $$, $counter++, map {int rand() * 10000} 0 .. rand() * 10;
}


=method create

Create user with name, email and credits

  $user->create(email => "filipo@kobkob.org", password => "Banana", credits => 100);


=cut


sub create {
use Mojo::Log;
use Data::Dumper;
my $log = Mojo::Log->new;

$log->debug ("user->create()");
#print Dumper \@_;

  my $self = shift;
  my $q = {@_};
  my $email = $q->{email} || $self->{email} || return undef;
  my $password = $self->hashfy($q->{password}) || $self->hashfy($self->{password}) || return undef;
  my $credits = $q->{credits} || $self->{credits} || return undef;
  my $sth;

$log->debug ("Calling DBI:\n");

#=begin comment

my $flag = 1;

eval {
  $sth = $self->{db}->prepare('INSERT INTO users (email, password, credits, create_time) VALUES (?,?,?, strftime(\'%s\',\'now\'))');
}; if ($@){
  print "Error: ";
  use Data::Dumper;
  print Dumper $@;
  return "ERROR";
}
eval {
  $flag = $sth->execute($email, $password, $credits);
}; if ($@ || $flag == 0){
  print "Error: $flag\n";
  use Data::Dumper;
  print Dumper $@;
  print Dumper DBI::errstr;
  return DBI::errstr if DBI::errstr;
  return undef
}

$log->debug("Creating new user:\n");
#print Dumper $sth; 

#=cut

  return $self->generate_token;
}
  

=method read

Read all from user identified by handle

  $user->read(email => "filipo@kobkob.org");
  $user->read(credit  => 300);
  $user->read(id  => 35);

Only one handle can be used. It returns the array of results

=cut

sub read {
  my $self = shift;
  my ($q, $v) = map{$_}@_;
  my $sth = eval { $self->db->prepare(
     'SELECT * FROM users WHERE '.$q.'='.$v
  ) } || return undef;
  $sth->execute;
  return $sth->fetchall_arrayref;
}

=method update

Update user identified by handle

  $user->update( email => "filipo@kobkob.org", values => { 
      credit => 400, 
      password => 'Foo' 
    }
  );

Only one handle can be used.

=cut

sub update {
  my $self = shift;
  my $h = shift;
  my $q = shift, 
  my %v = @_;
  my $values;
  return undef unless $values;
  foreach my $par (keys %v){ $values .= $par."=".$v{$par}."," }
  return undef unless $values;
  chop $values;
  my $sth = eval { $self->db->prepare(
     'UPDATE users SET '.$values.' WHERE '.$h.'='.$q
  ) } || return undef;
  $sth->execute;
  return 1;
}

=method delete

Delete user identified by handle

  $user->delete(email => "filipo@kobkob.org");
  $user->delete(id  => 35);

Only one handle can be used.

=cut


sub delete {
  my $self = shift;
  my ($q, $v) = map{$_}@_;
  my $sth = eval { $self->db->prepare(
     'DELETE FROM users WHERE '.$q.'='.$v
  ) } || return undef;
  $sth->execute;
  return 1;
}

=method check

Checks email and password

  die unless $user->check("email@kob.org", "blablabla");

=cut

sub check {
  my ($self, $email, $password) = @_;

  # Success
  return 1 if $self->read (email => $email)->{password} && 
    secure_compare  $self->read (email => $email)->{password} , $self->hashfy($password);

  # Fail
  return undef;
}

1;

