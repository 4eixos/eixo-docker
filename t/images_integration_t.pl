use strict;
use warnings;

use lib './lib';
use Test::More;
use Data::Dumper;
use JSON;

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

eval{
	#print $a->images->get(id=>'426130da57f7');

	#print $a->images->getAsync(

	#	id=>'426130da57f7', 

	#	onSuccess=>sub {

	##		print Dumper($_[0]);

	#	}

	#);


	#$a->images->getAllAsync(

	#	onSuccess=> sub {

	#		print Dumper($_[0]);

	#	}

	#);

	$a->images->createAsync(

		fromImage=>'ubuntu',

		onSuccess=>sub {
		
			print "FINISHED\n";		

		},

		onProgress=>sub{

			print $_[0] . "\n";
		}	

	);

	$a->waitForJobs;
};
if($@){
	print Dumper($@);
}

done_testing();
