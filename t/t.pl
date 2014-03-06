use t::test_base;

use Eixo::Docker::Api;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    
    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

    eval {
    
        my $name;

    	#
    	# Create a container
    	#
    	my $c = $a->containers->create(
    
    		Hostname => 'test',
    		Cmd => ['/bin/bash'],
    		Image => "base",
    		Name => $name = "testing_1233_" . int(rand(9999)),
    		Tty=>"false",
    
    		"AttachStdin"=>"true",
            "AttachStdout"=>"true",
            "AttachStderr"=>"true",
    		"OpenStdin" => "true",
    	);
    
        &change_state($c, 'up');
    
        my ($fcmd, $fout) = $c->attach(
        
            stdout=>1,
            stderr =>1,
            stdin=>1,
            stream=>1,
    
    	#f_line=>sub {
    	#	print "$_\n" foreach(@_);
    	#}
        );
    
        my @ids;
    
        my $cmd = <STDIN>;
        chomp($cmd);
        $fcmd->($cmd);
    
        while( my $cmd = <STDIN> ){
            print "enviando $cmd",
            chomp($cmd);
            last if($cmd eq 'exit');
    
            push @ids,$fcmd->($cmd);
        }
     
        <STDIN>;
        foreach(@ids){
            print $fout->($_);
        }

        $c->stop();
        $c->delete();
    
    };
    if($@){
        print Dumper($@);
    }
}
