use t::test_base;

BEGIN{
    use_ok("Eixo::Rest::Client");
}

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    

    # set log function
    # Eixo::Docker::Base::stashSet("f_log", sub {print join("\n",@_)});
    
    my @calls;
    
    my $a = Eixo::Rest::Client->new($ENV{DOCKER_TEST_HOST});
    
    #
    # Set a logger sub
    #
    $a->flog(sub {
        my ($api_ref, $data, $args) = @_;
    	push @calls, $data->[1];
    
    });
    
    
    $@ = undef;
    eval{
    	$a->noExiste;
    };
    ok($@ =~ /UNKNOW METHOD/, 'Non-existent Client methods launch exception');
    
    my $process_data = {
        onSuccess => sub {return $_[0]},
    };
    my $callback = sub {$_[0]};
    
    my $h = $a->getContainers(
        GET_DATA => {all => 1},
        PROCESS_DATA => $process_data,
        __callback => $callback
    );
    diag "Get all containers returns a containers list:";#. Dumper($h);
    
    ok(
    	ref $h eq "ARRAY", 
    	"Testing containers list command return an array"
    );
    
    ok($calls[0] eq 'get', 'Method call has been logged');#.Dumper(\@calls));
}

done_testing();
