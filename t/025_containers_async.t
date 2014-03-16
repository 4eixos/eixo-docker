use t::test_base;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    use_ok "Eixo::Docker::Api";
    use_ok "Eixo::Docker::Container";

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    
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
    
        		$a->containers->delete(
    			id => $c->ID, 
    			v => 1
    		);
    	}
    };
    die("Error cleaning: ".Dumper($@)) if($@);
    
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
    		onSuccess => sub {
    
    			$c = $_[0];
    		}
        );
        $a->waitForJobs;
    
    };
    ok(!$@, "New container created");
    ok($c && $c->Config->Memory == $memory, "Memory correctly asigned.");
    die(Dumper($c)) unless($c);
    
    #
    # test created container and start
    #
    eval {
        $c = $a->containers->getByName("testing123");
       
    };
    ok(!$@ && ref($c) eq "Eixo::Docker::Container", "getByName working correctly");
    
    #
    # up and down in async mode
    #
    
    if(&is_down($c)){
    	my $job_id = $c->startAsync(sub {return @_});
    	
    	$a->waitForJob($job_id);
    	
    	ok(
    		&is_up($c), 
    		"Test container has been started ok in async mode"
    	);
    }
    
    my $job_id = $c->stopAsync(sub {return @_});
    $a->waitForJob($job_id);
    ok(
    	&is_down($c), 
    	"Test container has been stopped ok in async mode"
    );
    
    
    #
    # check restart
    #
    eval{
    	&change_state($c, "up");
    };
    ok(!$@ && $c->status()->{Running}, "Test container has been started again");
    
    
    eval{
    	my $job_id = $c->restartAsync(t => 10, sub {return @_});
    	$a->waitForJob($job_id);
    };
    ok(!$@ && $c->status()->{Running}, "Test container has been restarted");
    
    
    #
    # kill
    #
    eval{
    	my $job_id = $c->killAsync(t => 10, sub {return @_});
    	$a->waitForJob($job_id);
    };
    ok(!$@ && !$c->status()->{Running}, "Test container has been killed");
    
    #$c->copyFile("path_to_file");
    
    #
    #  drop created container
    #
    eval{
    	my $job_id = $c->deleteAsync(delete_volumes => 1, sub {return @_});
    	$a->waitForJob($job_id);
    };
    ok(!$@, "Container deleted");

}

done_testing();
