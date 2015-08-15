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
	

    #
    # Get Api version
    #
    my $version = $a->version->get;
	
    ok(
	$version->Version && 
	$version->Os =~ /linux/i && 
	$version->KernelVersion &&
	$version->Arch,

    'Obtained version seems correct');
	
}

done_testing();
