package Sd88::App::WSCommands;
#ABSTRACT: Class for the singleton WSCommands schemas

use strict;
use warnings;
use File::Basename;
use Data::Dumper;
use JSON;

sub new { bless {}, shift }

sub create {
  my $me = shift;
  my $ws = shift;
  my $sc = shift;

  my $api = $ws->conditional(sub {shift()->validate_api_key(shift()->data->{api_key})});

#print Dumper $ws;
#print Dumper $sc;

  print "Creating ws commands ... \n";

  $api
	->type("REQUEST")
	->schema({
                id              => "test-command",
		type		=> "object",
		required	=> [qw/auth_key api_key/],
		properties	=> {
			auth_key	=> {type => "string"},
			api_key		=> {type => "string"},
		}
	})
	->command(test => sub {
		my $self = shift;
		my $data = shift;

           use Data::Dumper;
           print Dumper $data->data;

		#print "cmd1($data)$/";
		$data->reply("echo: " . $data->data)
	})
  ;
  # load commands from schema
  eval {
  print "Creating ws commands  from schema... \n";
  #print Dumper $sc;
  foreach my $s (@$sc){
    #print "Schema... \n"; 
    #print Dumper $s;
    my $code;
    if ($s->{command}->{perl}) { $code = $s->{command}->{perl} } 
    else { $code = $me->_get_code($s->{command}->{name})}
    my $command = '$api->type($s->{type})->schema($s->{schema})->command($s->{command}->{name}=> '. $code .');';
    print "\n";
    print $command;
    print "\n";
    eval ($command);if ($@){
      print "Error:\n"; 
      use Data::Dumper;
      print Dumper $@;
    } 
  }
  }; if ($@){
    print "Error: can't read schema ...\n";
    use Data::Dumper;
    print Dumper $@;
  }
  $me->{api} = $api;
  #print Dumper $me;
  return $api;
}
# from default file location
sub _get_code {
  my $me = shift;
  my $name = shift;
  my $file = dirname($0)."/../lib/Sd88/App/WSCommands/".$name.".pm";
  print "Opening file: ".$file."\n\n";
  my $code;
  #use Sd88::App::WSCommands::$name;
  open my $input, '<', $file or die "can't open $file: $!";
  while (<$input>) {
    #chomp;
    $code .= $_;
  }
  close $input or die "can't close $file: $!";
  return $code;
}

1;

