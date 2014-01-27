use strict;
use warnings;

use Test::More;
use Data::Dumper;
use JSON;

use Eixo::Docker::Api;


my @calls;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

#
# Set a logger sub
#
$a->flog(sub {

	my ($api_ref, $data, $args) = @_;

	push @calls, $data->[1];

});


# docker api main methods

my $lista = $a->containers->getAll();
my $container = $a->containers->get($id||$nombre||$obj);
my $container = $a->containers->create($attrs);
my $container = $a->containers->delete($id||$nombre||$obj);

my $params = {
	Hostname => "",
	User => "",
	Memory => 0,
	AttachStdin => undef,
	AttachStdout => undef,
	AttachStderr => undef,
	PortSpecs => undef,
	Tty => undef,
	OpenStdin => undef,
	StdinOnce => undef,
	Env => undef,
	Cmd => [],
	Dns => undef,
	Image => "ubuntu",
	Volumes => {"path_inside_container" => {}},
	VolumesFrom => "container_id",
	WorkingDir => "",
	ExposedPorts => {"22/tcp"=>{}}
	
};
my $c = $a->containers->create($params);
$c->stop;
$c->start;
$c->status;
$c->kill;
$c->copyFile("path_to_file");

$c->delete();


$a->images->getAll();
$a->images->get($id);
$a->images->create();
$a->images->delete();


done_testing();
