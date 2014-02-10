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

my @res;

eval{
	my $image = $a->images->get(id => "cca28c7ea449");
	 ok(
	 	ref $image eq "Eixo::Docker::Image" && $image->id =~ /^cca28c7ea449/, 
	 	"Images::get returns a docker image if exists"
	 );

	 $a->images->getAsync(

	 	# id=>'426130da57f7', 
	 	id => 'cca28c7ea449',
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

	# $a->images->createAsync(

	# 	fromImage=>'ubuntu',

	# 	onSuccess=>sub {
		
	# 		print "FINISHED\n";		

	# 	},

	# 	onProgress=>sub{

	# 		print $_[0] . "\n";
	# 	}	

	# );

};
if($@){
	print Dumper($@);
}


done_testing();
