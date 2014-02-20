use t::test_base;

use Data::Dumper;
use Eixo::Docker::Api;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

#
# Set a debugger sub
#
$a->client->flog(sub {

	my ($api_ref, $data, $args) = @_;
	#print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

});

my $container;

eval{

	$container = $a->containers->create(

	
		Hostname => 'test',
		Cmd => ["perl", "-e", '$i = 10; while($i--){print "OKKKKKKKK\n"; sleep(1)}'],
		Image => "ubuntu",
		Name => "testing123",
		Tty=>"false",
		"AttachStdin"=>"true",
     		"AttachStdout"=>"true",
     		"AttachStderr"=>"true",
		"OpenStdin" => "true",
	);

	
	&change_state($container, "up"), 

	$container->attach(

		stdout=>1,
		stderr=>0,
		stdin=>0,
		stream=>1,

	);

	<STDIN>;
};

if($@){
	print Dumper($@);
}

if($container){

	&change_state($container, 'down');	

	$container->delete;
}

done_testing();

