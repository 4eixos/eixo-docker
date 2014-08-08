use t::test_base;

use Eixo::Docker::Api;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

    #
    # Set a debugger sub
    #
    $a->client->flog(sub {

	    my ($api_ref, $data, $args) = @_;
	    #print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

    });


    # testing containers get methods

    my $lista;
    eval {
        $lista = $a->containers->getAll();
    };
    ok(!$@, "Testing containers#getAll");

    ok(ref $lista eq 'ARRAY', "'containers->getAll()' returns a list of containers");

    # exceptions
    eval {
        $a->containers->get();
    };
    ok($@->error eq 'Param needed', "Launch exception for required params not found");


    eval{
        my $id_ko = "340f03a2c2cfxx";
        my $c = $a->containers->get(id => $id_ko);
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

    eval{

        $a->images->create(fromImage=>'ubuntu',tag=>'14.04');

        my %h = (

            Hostname => 'test',
            Memory => $memory,
            Cmd => ["perl", "-e", 'while(1){sleep(1)}'],
            Image => "ubuntu:14.04",
            Name => "testing123",
        );

        $c = $a->containers->create(%h);
    };
    ok(!$@, "New container created");
    ok($c && $c->Config->Memory == $memory, "Memory correctly asigned");

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

}

done_testing();
