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

my ($image);

eval{

    	$image = $a->images->create(

        	fromImage=>'ubuntu',

     	);
    
	$image->history();
};
if($@){
	print Dumper($@);
}

done_testing();

