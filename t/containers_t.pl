use strict;
use warnings;

use lib './lib';
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


# testing containers api methods

my $lista = $a->containers->getAll();
ok(ref $lista eq 'ARRAY', "'API->containers->getAll()' returns a list of containers");
#print Dumper($lista);

# exceptions
eval {
	$a->containers->get();
};
ok($@->error eq 'Param needed', "Launch exception for required params not found");

my $id_ko = "340f03a2c2cfxx";
eval{
	my $c = $a->containers->get(id => $id_ko);
	print Dumper($c);
};
ok($@->error eq 'No such container', "Launch exception for non existent container with id $id_ko");
#print Dumper($@);

# create
$@ = undef;
my $c = undef;
my $h = {

	Hostname => 'test',
	#Memory => 512,
	Cmd => ["bash"],
	Image => "ubuntu",
};

eval{
	$c = $a->containers->create($h);
};
ok(!$@, "Container created with id ".Dumper($@));
ok($c && $c->Config->Memory == 512, "Memory correctly asigned");



#my $container = $a->containers->get($id||$nombre||$obj);
#my $container = $a->containers->create($attrs);
#my $container = $a->containers->delete($id||$nombre||$obj);
#
#my $params = {
#	Hostname => "",
#	User => "",
#	Memory => 0,
#	AttachStdin => undef,
#	AttachStdout => undef,
#	AttachStderr => undef,
#	PortSpecs => undef,
#	Tty => undef,
#	OpenStdin => undef,
#	StdinOnce => undef,
#	Env => undef,
#	Cmd => [],
#	Dns => undef,
#	Image => "ubuntu",
#	Volumes => {"path_inside_container" => {}},
#	VolumesFrom => "container_id",
#	WorkingDir => "",
#	ExposedPorts => {"22/tcp"=>{}}
#	
#};
#my $c = $a->containers->create($params);
#$c->stop;
#$c->start;
#$c->status;
#$c->kill;
#$c->copyFile("path_to_file");
#
#$c->delete();
#
#
#$a->images->getAll();
#$a->images->get($id);
#$a->images->create();
#$a->images->delete();


done_testing();
