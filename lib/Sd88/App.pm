package Sd88::App;

# ABSTRACT: Bootsptrap for a hybrid app

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use Sd88::App::Routes;
use Sd88::App::WSCommands;
use Sd88::App::Model::Users;
use Sd88::App::Model::Auth;
use Sd88::App::Model::Menu;
use Sd88::App::Model::Contents;
use DBI;
use Config::Any;
use Config::Any::XML;

our $VERSION = "0.0.1";

sub startup {
    my $self = shift;

    $self->secrets( ['im so secret'] );
    $self->config(
        hypnotoad => {
            listen => [
                'https://*:443?cert=/etc/tls/domain.crt&key=/etc/tls/domain.key'
            ]
        }
    );

    # change public dir to be compatible with cordova
    push @{ $self->static->paths }, 'www';

    # connect to database
    my $dbh = DBI->connect( "dbi:SQLite:app.db", "", "" )
      or die "Could not connect";

    # read configuration
    my $config = Config::Any::XML->load('config.xml');
    my %CONF   = %$config;

    # prepare and load WS Commands from config.xml api
    my $cmds =
      Sd88::App::WSCommands->new( name => "SD88", version => $VERSION );
    my $schema =
      ref( $CONF{api}->{ws} ) eq 'ARRAY'
      ? $CONF{api}->{ws}
      : [ $CONF{api}->{ws} ] || [ {} ];
    my $wspath = $CONF{wspath} || "/ws";
    my $cws = $self->plugin( CommandWS => { path => $wspath } );
    my $api = $cws->conditional(
        sub {
            my $self = shift;
            my $c    = shift;
            my $key  = $c->{msg}->{data}->{api_key};

            #print "My api key: ";
            #use Data::Dumper; print Dumper $key;
            $self->validate_api_key($key);
        }
    );
    $cmds->create( $api, $schema );

    #use Data::Dumper;
    #print "API at begin:";
    #print Dumper $cmds;

=begin comment

  $cmds
	->type("REQUEST")
	->schema({
		type		=> "object",
		required	=> [qw/auth_key api_key/],
		properties	=> {
			auth_key	=> {type => "string"},
			api_key		=> {type => "string"},
		}
	})
	->command(cmd1 => sub {
		my $self = shift;
		my $data = shift;

           use Data::Dumper;
           print Dumper $data->data;

		#print "cmd1($data)$/";
		$data->reply("echo: " . $data->data)
	})
;

=cut

    $self->helper( db => sub { $dbh } );

    #$self->helper ( db => $dbh );

    $self->helper(
        users => sub {
            state $users = Sd88::App::Model::Users->new( $self->db );
        }
    );
    $self->helper(
        auth => sub {
            state $auth = Sd88::App::Model::Auth->new( $self->db );
        }
    );
    $self->helper(
        menus => sub {
            state $users = Sd88::App::Model::Menu->new( $self->db );
        }
    );
    $self->helper(
        contents => sub {
            state $users = Sd88::App::Model::Contents->new( $self->db );
        }
    );

    $self->helper(
        validate_api_key => sub {
            print "validate_api_key(@_)$/";
            my $self = shift;
            my $key  = shift;

            return !!$key;
        }
    );

    $self->helper(
        validate_auth_key => sub {
            print "validate_auth_key(@_)$/";
            my $self = shift;
            my $key  = shift;

            my $auth = $self->resultset("Auth")
              ->find( { auth_key => $key, logout => undef } );
            if ($auth) {
                $self->stash->{device} = $auth->device;
                $self->stash->{user}   = $self->stash->{device}->user;
                return $auth if $self->stash->{user}->active;
            }
        }
    );

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
