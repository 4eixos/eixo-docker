use t::test_base;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
 
    eval{ require "HTTP/Server/Simple/CGI.pm"};
    skip "HTTP::Server::Simple::CGI not installed", 2 if($@);

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
    
    my ($pid, $container, $image);
    
    eval{
    
    	#
    	# We create a test server listening in the 6884 port
    	#
        	$pid = &TestServer::start_server;
    
        	$image = $a->images->create(
    
            		fromImage=>'ubuntu',
         	);

		my $current = $image->id;    

        
         	ok($image = $image->insertFile(
        
        		url=>'http://0.0.0.0:6884/test1',
        		path=>'/tmp/test1',
        		id=>$image->id
        
          	), "Insert a file into image");
         		
    
    	#
    	# Check if the file is correctly inserted in the image. 
    	#
    	
    	# Launching a container with the new image
    	$container = $a->containers->create(
    
    		Hostname => 'test',
    
    		Cmd => ["/bin/bash"],
    
    		Image => $image->id,
    
    		Name => "testing_insert_file",
    	);
    
    	# starting it
    	&change_state($container, "up");
    
    	#
    	# Copying the file
    	#
    	my $salida = $container->copy(Resource=>'/tmp/test1');

    	ok(
    
    		$salida =~ /test1\,OK/,
    
    		'A new file has been inserted in the image'
    	);

    };
    if($@){
    	print Dumper($@);
    }

    #
    # Cleaning up
    #

    if($pid){
        kill(9, $pid);
    }

    if($container){

      	&change_state($container, "down");

        $container->delete();
    }

    if($image){
        $image->delete();
    }

    
    
}

done_testing();


#
# Test file server
#
package TestServer;

use parent -norequire, qw(HTTP::Server::Simple::CGI);

sub start_server{
	
	my $server =  __PACKAGE__->new;

	$server->port(6884);

	$server->background();
}

sub handle_request{
	my ($self, $cgi) = @_;
		
	my $path = $cgi->path_info;

	print "HTTP/1.0 200 OK\r\n";
	print $cgi->header(-type  =>  'text/plain');

	if($path eq '/test1'){
		print "test1,OK\n";
	}
}


