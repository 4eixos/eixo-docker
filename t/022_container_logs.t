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
use IO::Handle;
autoflush STDOUT 1;

my($i,$j) = (0,0); 
while(1){

    print "Sent cmd ".$i++." by STDOUT\n";
    print STDERR "Send cmd ".$j++." by STDERR\n";
    select(undef,undef,undef,0.25);

}'
];
#$container_config{Name} = "testing";

#my $container = $a->containers->getByName("testing") || 
#            $a->containers->create(%container_config);
        
        $container = $a->containers->create(%container_config);
    	&change_state($container, 'up');

        sleep(1);

    	my $fcmd = $container->attach(
    
    		stdout=>1,
            stderr => 1,
    		stdin=>0,
    		stream=>0,
            logs => 1,
            #f_process => sub {print "mi f_line: ".$_[0]},
        );

        my @res = grep {$_ ne ''} split("\n", $fcmd->());
        # print Dumper(\@res);
        ok(
            (grep {/STDOUT/} @res) > 0 &&
            (grep {/STDERR/} @res) > 0 ,

            "Attach stdout and stderr receives STDOUT & STDERR logs"
        );

        $fcmd = $container->attach(
    
            stdout=>1,
            stderr => 0,
            stdin=>0,
            stream=>0,
            logs => 1,
        );



        @res = grep {$_ ne ''} split("\n", $fcmd->());
        # print Dumper(\@res);
        ok(
             (grep {$_ !~ /STDOUT/} @res) == 0,

             "Attach only stdout receives only container STDOUT logs"
        );

        $fcmd = $container->attach(
    
            stdout=>0,
            stderr => 1,
            stdin=>0,
            stream=>0,
            logs => 1,
        );

        @res = grep {$_ ne ''} split("\n", $fcmd->());
        # print Dumper(\@res);
        ok(
             (grep {$_ !~ /STDERR/} @res) == 0,

             "Attach only stderr received only container STDERR logs"
        );
    };
    if($@){
        die($@);
    }

    if($container){
        &change_state($container, "down");
        $container->delete();
    }
}

done_testing()
