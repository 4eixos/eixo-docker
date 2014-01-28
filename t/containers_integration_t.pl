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
$a->client->flog(sub {

	my ($api_ref, $data, $args) = @_;
	
	print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

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
# 0. Drop container testing123 if exists
print "Cleaning\n";
eval {
	my $c = $a->containers->getByName("testing123");
    $a->containers->delete(id => $c->ID) if($c);
};

# 1. create container
$@ = undef;
my $c = undef;
my $memory = 128*1024*1024; #128MB

my %h = (

	Hostname => 'test',
	Memory => $memory,
	Cmd => ["bash"],
	Image => "ubuntu",
    Name => "testing123",
);

eval{
	$c = $a->containers->create(%h);
};
ok(!$@, "New container created");
ok($c && $c->Config->Memory == $memory, "Memory correctly asigned");

# 2 . test created container
eval {
    $c = $a->containers->getByName("testing123");
};
ok(!$@ && ref($c) eq "Eixo::Docker::Container", "getByName working correctly");
#die(Dumper($c));

#$c->stop;
#$c->start;
#$c->status;
#$c->kill;
#$c->copyFile("path_to_file");


# 4. drop created container
eval{
	$a->containers->delete(id => $c->ID);
};
ok(!$@, "Container deleted");


done_testing();
