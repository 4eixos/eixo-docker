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

	my $f = $a->containers->attach(

		id=>'7898d5f0f779',
		tty=>undef,

		stdout=>1,
		stderr=>0,
		stdin=>1,
		stream=>1,

	);

	$f->('/bin/touch /tmp/a');

	for(1..10){

		$f->('/bin/cat /tmp/a');

		sleep(1);

	}

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

