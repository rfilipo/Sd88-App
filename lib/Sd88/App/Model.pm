package Sd88::App::Model;
#ABSTRACT: Model objects interface

use DBI;
use Mojo::Util 'secure_compare';

my $dbh;
eval {
  $dbh = DBI->connect("dbi:SQLite:app.db","","") or die "Could not connect";
  # has db => $dbh;
}; if ($@){
  print "Error:\n";
}

sub new { my $self=shift; bless { @_ }, $self; $self->db = sub { $dbh }; return $self; }

1;
