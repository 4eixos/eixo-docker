use t::test_base;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    use_ok "Eixo::Docker::Api";
    use_ok "Eixo::Docker::Image";

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    
    my @calls;
    #
    # Set a logger sub
    #
    $a->flog(sub {
    
        my ($api_ref, $data, $args) = @_;
    
        print Dumper(\@_);
    
        push @calls, $data->[1];
    
    });
    
    my @res;
    
    my ($image);
    
    eval{
    
        	$image = $a->images->create(
                
                fromImage=>'ubuntu',
                tag => '14.04',
    
         	);
        
    	print Dumper([$image->history()]);
    };
    if($@){
    	print Dumper($@);
    }
}

done_testing();

