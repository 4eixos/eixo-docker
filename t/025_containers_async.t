use t::test_base;

use Eixo::Docker::Api;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

#
# Set a debugger sub
#
$a->client->flog(sub {

	my ($api_ref, $data, $args) = @_;
	#print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

});


# testing containers get methods

my $lista = [];
my $job = $a->containers->getAllAsync(
    onSuccess => sub {
        $lista =  $_[0];
    }
);
$a->waitForJob($job);
ok(ref $lista eq 'ARRAY', "'containers->getAllAsync()' returns a list of containers");

# exceptions
eval {
	$a->containers->getAsync(
        onSuccess => sub {return @_}
    );
    $a->waitForJobs;
};
ok($@->error eq 'Param needed', "Launch exception for required params not found");

eval{
	my $id_ko = "340f03a2c2cfxx";
	my $c = $a->containers->getAsync(
        id => $id_ko,
        onSuccess => sub {return @_}
    );
    $a->waitForJobs;
};
ok($@->error eq 'No such container', "Launch exception for non existent container");

#
# TEST CONTAINER LIFECYCLE
#
# 0. Drop container testing123 if exists
print "Cleaning\n";
eval {
	my $c = $a->containers->getByName("testing123");
	if($c){
		&change_state($c, "down");
    		$a->containers->delete(id => $c->ID, v => 1);
	}
};
die(Dumper($@)) if($@);

#
# create container
#

$@ = undef;
my $c = undef;
my $memory = 128*1024*1024; #128MB

my %h = (

	Hostname => 'test',
	Memory => $memory,
	Cmd => ["perl", "-e", 'while(1){sleep(1)}'],
	Image => "ubuntu",
	Name => "testing123",
);

eval{
	$a->containers->createAsync(
        %h, 
        onSuccess => sub {$c = $_[0]}
    );
    $a->waitForJobs;

};
ok(!$@, "New container created".Dumper($@));
ok($c && $c->Config->Memory == $memory, "Memory correctly asigned");

die("end");
#
# test created container and start
#
eval {
    $c = $a->containers->getByName("testing123");
   
};
ok(!$@ && ref($c) eq "Eixo::Docker::Container", "getByName working correctly");

ok( 
	&change_state($c, "up"), 
	"The container has been started"
);

#
# stop container
#
eval{
	&change_state($c, "down");
};
ok(!$@ && !$c->status()->{Running}, "Test container has been stopped");

#
# check restart
#
eval{
	&change_state($c, "up");
};
ok(!$@ && $c->status()->{Running}, "Test container has been started again");


eval{
	$c->restart(t => 10);
};
ok(!$@ && $c->status()->{Running}, "Test container has been restarted");


#
# kill
#
eval{
	$c->kill(t => 10);
};
ok(!$@ && !$c->status()->{Running}, "Test container has been killed");

#$c->copyFile("path_to_file");

#
#  drop created container
#
eval{
	$c->delete(delete_volumes => 1);
};
ok(!$@, "Container deleted");


done_testing();
