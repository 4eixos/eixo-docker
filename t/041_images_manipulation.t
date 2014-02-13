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
#$a->flog(sub {
#
#    my ($api_ref, $data, $args) = @_;
#
#    push @calls, $data->[1];
#
#});

my @res;

eval{

    my ($i) = $a->images->create(

        fromImage=>'busybox',

     );

     ok($i->insertFile(), "Inserta a file into image");
     		

};
if($@){
	print Dumper($@);
}


done_testing();
