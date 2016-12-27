package Sd88::App::Model::Users;
#ABSTRACT: Model for Users objects, they have id, email, password and credits

use strict;
use warnings;

use Mojo::Util 'secure_compare';

sub new { bless {
id => undef,
email => undef,
password => undef,
credits => undef
}, shift }

=method create

Create user with name and email

  $user->create(email => "filipo@kobkob.org", password => "Banana");


=cut


sub create {
  my $self = shift;
  my $q = {@_};
  my $email = $q->{email} || return undef;
  my $password = $q->{password} || return undef;
  my $sth = eval { $self->db->prepare('INSERT INTO users VALUES (?,?)') } || return undef;
  $sth->execute($email, $password);
  return 1;
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
     'SELECT * FROM people WHERE '.$q.'='.$v
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
     'DELETE FROM people WHERE '.$q.'='.$v
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
    secure_compare  $self->read (email => $email)->{password} , $password;

  # Fail
  return undef;
}

1;

