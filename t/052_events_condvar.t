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

		# fork a process to perform changes in the docker 
		unless(fork){
			
			eval{

				sleep(1);

				# we start the container			
				&change_state($c, "up");

				sleep(1);

				&change_state($c, "down");

				sleep(1);

				$c->delete;

				exit 0;
			};

			if($@){
				print "CRASHED TEST_CLIENT: $@";
				exit 1;
			}
		}

		# block in the main process for testing purposes

		my $total_events = 0;

		foreach my $e (qw(start stop rename destroy)){

			$pool->registerEvent(

				id=>$c->Id,

				status=>$e,

				code=>sub {
					my ($event) = @_;

					print "RECEIVED EVENT " . $event->{status} . "\n";

					$total_events++;

					if($event->{status} eq "destroy"){

						$c = undef;

						goto CALCULATE;
					}
				}
				
			);
		}

		$pool->condvar;

		CALCULATE:

		ok($total_events == 3, "Los tres eventos se han registrado");
	
	};
	if($@){
		print Dumper($@); die 1;
	}
}


$c->delete(delete_volumes=>1) if($c);


done_testing();
