use t::test_base;

use Eixo::Docker::Api;

use_ok("Eixo::Docker::RequestRawStream");

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    #
    # Set a debugger sub

    $a->client->flog(sub {
    
    	my ($api_ref, $data, $args) = @_;
    
    });
    
    my ($container, $name, @jobs);
    
    eval{
    
        #$a->images->create(fromImage=>'ubuntu');
    	
    	#
    	# Create a bash container
    	#
        my %container_config = (
    		Hostname => 'test',
    		Cmd => ['/bin/bash'],
    		Image => "ubuntu",
    		Name => $name = "testing_1233_" . int(rand(9999)),

            Tty => "false",
    		"AttachStdin"=>"true",
            "AttachStdout"=>"true",
            "AttachStderr"=>"true",
    		"OpenStdin" => "true",
        );

        $container_config{Cmd} = ['perl','-e','
my($i,$j) = (0,0); 
while(1){


    select(undef,undef,undef,0.05);

    print "Sent cmd ".$i++." by STDOUT\n";

    print STDERR "Send cmd ".$j++." by STDERR\n";
}'
];
        $container_config{Name} = "testing_1233_".int(rand(9999));

    	$container = $a->containers->create(%container_config);
    	&change_state($container, 'up');

        sleep(5);

        print "atachandonos o container\n";
    	my $fcmd = $container->attach(
    
    		stdout=>1,
            stderr => 1,
    		stdin=>0,
    		stream=>0,
            logs => 1,
            f_line => sub {print "mi f_line: ".$_[0]},
        );

        $fcmd->();
    };
    if($container){
        print "limpiando\n";
        &change_state($container, "down");
        $container->delete();
    }
}

done_testing();
