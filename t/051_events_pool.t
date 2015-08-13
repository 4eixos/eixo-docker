use t::test_base;

use strict;
use Eixo::Docker::Api;

my $c;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

	eval{

	    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
	
	    #
	    # Set a debugger sub
	    #
	    $a->client->flog(sub {
	
		    my ($api_ref, $data, $args) = @_;
		    #print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";
	
	    });
		
		# we obtain a pool of events
		my $pool = $a->eventPool;
	
		my @events;
		
		# we create a container
	
		my $C = "testing_" .int(rand(1000));	
	
		eval{
		
		    $a->images->create(fromImage=>'ubuntu',tag=>'14.04');
		
		    my %h = (
		
		        Hostname => 'test',
		        Cmd => ["perl", "-e", 'while(1){sleep(1)}'],
		        Image => "ubuntu:14.04",
		        Name => $C ,
		    );
		
		    $c = $a->containers->create(%h);
		};
		ok(!$@, "New container created ");

		# we register an event of creation
		$pool->registerEvent(

			id=>$c->Id,

			status=>'create', 

			code=>sub {

				push @events, "CREATED";

			}
		);
	
		$pool->registerEvent(

			id=>$c->Id,

			status=>'destroy',

			code=>sub {

				push @events, "DESTROYED";

			}

		);


		$c->delete(delete_volumes=>1);

		$c = undef;

		sleep(3);	

		$pool->run;

		ok((grep { $_ eq "CREATED"} @events), "Created event has been executed");
		ok((grep { $_ eq "DESTROYED"} @events), "Destroyed event has been executed");
	
	};
	if($@){
		print Dumper($@); die 1;
	}
}

$c->delete(delete_volumes=>1) if($c);

done_testing();
