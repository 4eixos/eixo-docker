use t::test_base;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    use Eixo::Docker::Api;

    use_ok(Eixo::Docker::Terminal);

    my ($name, $c);

    eval{

        my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

    	$@ = undef;

    	my $memory = 128*1024*1024; #128MB
    	
    	my %h = (
    	
    		Name => $name = "testing_" . int(rand(1000)),

    		Memory=>$memory,

        	Cmd => ['/bin/bash'],

        	Image => "ubuntu",

        	Tty=>"false",
        
    		"AttachStdin"=>"true",
    		"AttachStdout"=>"true",
    		"AttachStderr"=>"true",
    		"OpenStdin" => "true",
        );

        $c = $a->containers->create(%h);

    	ok(!$@, "New container created");

    	ok($c && $c->Config->Memory == $memory, "Memory correctly asigned");

        	#
        	# Run it
        	#
            &change_state($c, 'up');


    	#
    	# Creating a terminal for testing
    	#
    	my $t = Eixo::Docker::Terminal->new(

    		container=>$c

    	);

    	#
    	# Send a trivial command
    	#
    	$t->sendS('/bin/echo', "test66", '>', '/tmp/test1');

    	my $salida = $t->send('/bin/cat', '/tmp/test1');
    	
    	is($salida, 'test66', 'Both send and sendS work');

    	#
    	# End the console
    	#
    	$t->send('exit');


    };
    if($@){
    	print Dumper($@);
    }

    if($c){

        &change_state($c, 'down');
    	# clean the container
    	$c->delete;
    }
}

done_testing();
