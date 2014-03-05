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
    
    });
    
    my ($container, $name);
    
    eval{
    
    	$a->images->create(fromImage=>'ubuntu');
    	
    	#
    	# Create a container
    	#
    	$container = $a->containers->create(
    
    		Hostname => 'test',
    		Cmd => ['/bin/bash'],
    		Image => "ubuntu",
    		Name => $name = "testing_1233_" . int(rand(9999)),
    		Tty=>"false",
    
    		"AttachStdin"=>"true",
         		"AttachStdout"=>"true",
         		"AttachStderr"=>"true",
    		"OpenStdin" => "true",
    	);
    
    	#
    	# Run it
    	#
    	&change_state($container, 'up');
    	
    	sleep(1);
    
    	#
    	# Attach to it
    	#
    	my $fcmd = $container->attach(
    
    		stdout=>1,
    		stdin=>1,
    		stream=>1,
    	);
    
    	#
    	# Create a couple of files
    	# 
    	$fcmd->('/bin/echo "TEST1" > /tmp/test');	
    
    	$fcmd->('/bin/echo "TEST2" > /tmp/test2');	
    
    	sleep(1);
    	#
    	# Retrieve them
    	#
    	ok($container->copy(Resource=>'/tmp/test') =~ /TEST1/, 'File was created');
    
    	ok($container->copy(Resource=>'/tmp/test2') =~ /TEST2/, 'File was created(2)');
    
    	#
    	# We stop the container	
    	#
    	$fcmd->('exit');
    };
    
    if($@){
    	print Dumper($@);
    }
    
    if($container){
    
    	&change_state($container, 'down');
    
        #$container->delete;
    }

}
done_testing();
