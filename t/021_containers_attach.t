use t::test_base;

use Eixo::Docker::Api;

use Config;


SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    skip "Perl installation without itreads support", 2 unless($Config{'useithreads'});

    use_ok("Eixo::Docker::RequestRawStream");

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    #
    # Set a debugger sub
    #
    $a->client->flog(sub {
    
    	my ($api_ref, $data, $args) = @_;
    
    });
    
    my ($container, $name, @jobs);
    
    eval{
    
        $a->images->create(fromImage=>'ubuntu', tag=>'14.04');
    	
    	#
    	# Create a bash container
    	#
        my %container_config = (
    		Hostname => 'test',
    		Cmd => ['/bin/bash'],
    		Image => "ubuntu:14.04",
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
            timeout => 1,
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
    	# push @jobs, $fcmd->('/bin/echo "TEST2" 1>&2');
    
        # print Dumper(\@results);use Data::Dumper;

        # esperamos a que finalicen os jobs enviados
        my @results =  $fout->();
        ok($results[0] eq '' && $results[1] eq '', "Testing jobs with stdout redirected");
        ok($container->copy(Resource=>'/tmp/test') =~ /TEST1/, 'File was created');
        ok($container->copy(Resource=>'/tmp/test2') =~ /TEST2/, 'File was created (2)');

        ok($results[2] eq "TEST1\n", "Testing job with simple stdout response");
        # ok($results[3] eq "TEST2\n", "Testing job with stderr response");

    	#
    	# Retrieve them
    	#
        #print Dumper($container->copy(Resource => "/tmp/test"));

        my $jid = $fcmd->("find /");
        my $res = $fout->($jid);
        ok(length($res) > 1000000, "Test to receive a long string");
    	#
    	# We stop the container	
    	#
        $fcmd->('exit');
        $fout->();
    

    };
    if($@){
    	print "Exception produced: ".Dumper($@);
    }

    if($container){
        
        &change_state($container, 'down');
        
        $container->delete;
    }

}
done_testing();
