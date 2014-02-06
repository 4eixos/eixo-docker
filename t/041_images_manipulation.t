use strict;
use warnings;

use lib './lib';
use Test::More;
use Data::Dumper;
use JSON;
use t::test_base;

use Eixo::Docker::Api;

my @calls;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

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

    
     	ok($image = $image->insertFile(

		url=>'http://192.168.0.8:6884/test1',
		path=>'/tmp/test1',
		id=>$image->id

      	), "Insert a file into image");
     		

	

	#
	# Check if the file is correctly inserted in the image. 
	#
	
	# Launching a container with the new image
	$container = $a->containers->create(

		Hostname => 'test',

		Cmd => ["perl", "-e", 'while(1){sleep(1)}'],

		Image => $image->id,

		Name => "testing_insert_file",
	);

	# starting it
	&change_state($container, "up");

	sleep(2);

	#
	# Copying the file
	#
	ok(

		$container->copy(Resource=>'/tmp/test1') =~ /test1\,OK/,

		'A new file has been inserted in the image'
	);

};
if($@){
	print Dumper($@);
}

done_testing();

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

#
# Test file server
#
package TestServer;

use  parent qw(HTTP::Server::Simple::CGI);

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



