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
    
        push @calls, $data->[1];
    
    });
    
    my @res;
    
    eval{
        $a->images->create(
    
            fromImage=>'busybox',
            tag => 'latest',
    
            onSuccess=>sub {
            
                print "FINISHED\n";     
    
            },
    
            onProgress=>sub{
    
                print $_[0] . "\n";
            }   
    
        );
    
    	 my $image = $a->images->get(id => "busybox");
    	 ok(
    	 	ref($image) eq "Eixo::Docker::Image", 
    	 	"Images::get returns the busybox docker image if exists"
    	 );
    
    	 $a->images->getAsync(
    	 	id => 'busybox',
    	 	onSuccess=>sub {
    
    	 #		print Dumper($_[0]);
    	 		print "Encontrada imagen 426...\n";
    	 		#print Dumper(@_);
    	 		push @res, $_[0];
    
    	 	},
    	 	onError => sub {
    	 		print "No se encontrou tal imaxen\n";
    	 		print Dumper(@_);
    	 	}
    
    	 );
         $a->waitForJobs;
         ok(scalar @res == 1 && ref($res[0]) eq "Eixo::Docker::Image", "Get image with an async request");
    
         my $res;
         $a->images->getAllAsync(
    
    		onSuccess=> sub {
    
                $res = $_[0];
    		}
        );
        $a->waitForJobs;
        ok(ref $res eq "ARRAY", "List images returns an array");
    
        ok(
            scalar(
                grep {$_ =~ /^busybox/} map {@{$_->RepoTags}} @$res
            ), 
            "Find busybox image in image list"
        );
    
    };
    if($@){
    	print Dumper($@);
    }

}

done_testing();
