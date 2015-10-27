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

	# we create a container

	my $C = "testing_" .int(rand(1000));
        my $c;

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

	my $e;
	my $ee;

	my $t = time + 5;

	eval{
    		$e = $a->events->get(since=>time - 10, until=>$t);
	};
	ok(!$@ && @{$e->{Events}} > 0, 'We have collected some events');

	eval{

		$ee = $a->events->get(
	
			since=>$t - 5, 
	
			until=>$t, 
	
			filters=>{

				container => [$c->Id]

			}

			
		);

	};

	ok(!$@ && @{$ee->{Events}} == 1, 'Filters work properly');

	ok((grep {

		$_->{id} eq $c->Id 

	} @{$e->Events}), "Something happened with our container ");

	$c->delete(delete_volumes=>1);
	
}

done_testing();
