use t::test_base;

use Eixo::Docker::Api;

use_ok("Eixo::Docker::RequestRawStream");

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    #
    # Set a debugger sub
    #
    $a->client->flog(sub {
    
    	my ($api_ref, $data, $args) = @_;
    
    });
    
    my ($container, $name, @jobs);
    
    eval{
    
        $a->images->create(fromImage=>'ubuntu');
    	
    	#
    	# Create a bash container
    	#
        my %container_config = (
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

        $container = $a->containers->create(%container_config);

    	#
    	# Run it
    	#
        &change_state($container, 'up');

    	# Attach to it
    	#
    	my ($fcmd,$fout) = $container->attach(
    
    		stdout=>1,
    		stdin=>1,
    		stream=>1,
            #f_line => sub {
            #    print $_[0];
            #},
    	);
    
    	#
    	# Create a couple of files
    	# 
        #push @jobs, $fcmd->('/bin/echo "TEST1" && find / && sleep 10');

        push @jobs, $fcmd->('/bin/echo "TEST1" > /tmp/test');
        push @jobs, $fcmd->('/bin/echo "TEST2" > /tmp/test2');
        push @jobs, $fcmd->('/bin/echo "TEST1"');
    	push @jobs, $fcmd->('/bin/echo "TEST2"');
    
        # esperamos a que finalicen os jobs enviados
        $fout->();
    
    	#
    	# Retrieve them
    	#
        #print Dumper($container->copy(Resource => "/tmp/test"));
        ok($container->copy(Resource=>'/tmp/test') =~ /TEST1/, 'File was created');
        ok($container->copy(Resource=>'/tmp/test2') =~ /TEST2/, 'File was created (2)');

        my $jid = $fcmd->("find /usr");
        my $res = $fout->($jid);
        ok(length($res) > 1000000, "Test to receive a long string");
    	#
    	# We stop the container	
    	#
        $fcmd->('exit');
        $fout->();
    

    };
    if($@){
    	print Dumper($@);
    }

    if($container){
        
        &change_state($container, 'down');
        
        $container->delete;
    }

}
done_testing();
