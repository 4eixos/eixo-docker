use t::test_base;

BEGIN{
    use_ok("Eixo::Docker::Api");
}

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    
    my $callback = sub {$_[0]};
    
    my ($proto,$host) = split ('://', ($ENV{DOCKER_TEST_HOST} || $ENV{DOCKER_HOST}));

    foreach my $args (

        ["tcp://$host"],
        ["http://$host"],
        [host => $host, tls_verify => 0],
        [host => "tcp://$host"],
        [$host],

    ){
        my $a = Eixo::Docker::Api->new(@$args);
    
        my $h = $a->version->get();
        

        ok(
        	ref $h eq "Eixo::Docker::Version", 
        	"Testing docker initialization api connection to ".$a->host
        );
    }

    # check https fails
    foreach my $args (

        ["tcp://$host", tls_verify => 1, ca_file => '/tmp/ca.pem',cert_file => '/tmp/cert.pem', key_file=>'/tmp/key.pem'],
        [host =>"https://$host", ca_file => '/tmp/ca.pem',cert_file => '/tmp/cert.pem', key_file=>'/tmp/key.pem'],
        ["https://$host", ca_file => '/tmp/ca.pem',cert_file => '/tmp/cert.pem', key_file=>'/tmp/key.pem'],

    ){
        my $a = Eixo::Docker::Api->new(@$args);
    
        eval{
            my $h = $a->getVersion();
        }; 
        #print $@;
        ok(
            $@,
        	'Testing docker https connection to '.$a->host
        );
    }
    
}

done_testing();
