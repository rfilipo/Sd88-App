package Sd88::App;
# ABSTRACT: Bootsptrap for a hybrid app

use Mojo::Base 'Mojolicious';
use Sd88::App::Routes;
use Sd88::App::Model::Users;
use Sd88::App::Model::Menu;
use Sd88::App::Model::Contents;
use DBI;
use XML::Config;

sub startup {
  my $self = shift;
  # change public dir to be compatibel with cordova
  push @{$self->static->paths}, 'www';

  # connect to database
  my $dbh = DBI->connect("dbi:SQLite:app.db","","") or die "Could not connect";

  # read configuration
  my $cfg = new XML::Config; 
  my %CONF = $cfg->load_conf("config.xml");

use Data::Dumper;
print Dumper \%CONF;

  # shortcut for use anywhere
  $self->helper ( db => sub { $dbh }); 

  $self->helper( users => sub { 
    state $users = Sd88::App::Model::Users->new; 
  });
  $self->helper( menus => sub { 
    state $users = Sd88::App::Model::Menu->new;
  });
  $self->helper( contents => sub { 
    state $users = Sd88::App::Model::Contents->new 
  });

  # Documentation browser under "/perldoc"
  #$self->plugin('PODRenderer');

  # Routes
  my $r = $self->routes;
  Sd88::App::Routes::create_routes($r);
}

=head1 SEE ALSO

=for :list
* L<Sd88::App::Model::Users>
* L<Sd88::App::Model::Menu>
* L<Sd88::App::Model::Contents>

=cut

1;
