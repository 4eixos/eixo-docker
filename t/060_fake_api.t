use t::test_base;

SKIP: {

    eval{ require "HTTP/Server/Simple/CGI.pm"};

    skip "HTTP::Server::Simple::CGI not installed", 2 if($@);

    use_ok(Eixo::Rest::ApiFakeServer);

    my $pid;
    
    eval{
    
    
    	#
    	# We can create an rest api with arbitrary methods
    	# that can accept arbitrary requests
    	#
    	$pid = Eixo::Rest::ApiFakeServer->new(
    
    		listeners=>{
    
    			'/test/a' => {
    
    				body=>sub {
    
    					print "TEST1";
    
    				}
    
    			},
    
    			'/test2/b' =>  {
    
    				body=>sub {
    
    					print $_[0]->cgi->{param}->{POSTDATA}->[0];
    
    				}
    
    			}
    
    
    		}
    
    
    	)->start('8085');
    
    	#
    	# We can connect now to it
    	#
        	my $a = Eixo::Rest::Api->new('http://localhost:8085');
    
    	$a->getTest(
    	
    		args=>{
    
    			action=>'a',
    			__format=>'RAW',
    			__implicit_format=>1,
    
    		},
    
    		__callback=>sub {
    
    			is($_[0], 'TEST1' , 'Request was successfull');
    
    		}
    	);
    
    	$a->postTest2(
    
    		args=>{
    
    			action=>'b',
    			
    			list=>[1,2,3,4,5],
    		},
    
    		post_params=>[qw(list)],
    
    		__callback=>sub {
    
    			is(ref($_[0]), 'HASH', 'Post params are ok');
    
    			is(
    				scalar(@{$_[0]->{list}}), 
    
    				5, 
    
    				'Request with post params is successfull'
    			);
    
    		}	
    
    	);
    
    
    };
    
    if($@){
    	print Dumper($@);
    }
    
    kill(9, $pid) if($pid);	

}
done_testing();
