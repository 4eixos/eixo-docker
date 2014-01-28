use strict;
use warnings;

use Test::More;
use Data::Dumper;
use JSON;

use lib './lib';

use Eixo::Rest::Client;

# set log function
# Eixo::Docker::Base::stashSet("f_log", sub {print join("\n",@_)});

my @calls;

my $a = Eixo::Rest::Client->new("http://localhost:4243");

#
# Set a logger sub
#
$a->flog(sub {

	my ($api_ref, $data, $args) = @_;

	push @calls, $data->[1];

});


$@ = undef;
eval{
	$a->noExiste;
};

ok($@ =~ /UNKNOW METHOD/, 'Controla metodos no existentes');

my $h = JSON->new->decode($a->getContainers(all => 1));

print Dumper($h);

ok(
	ref $h eq "ARRAY", 
	"Testing containers list command return an array"
);

ok($calls[0] eq 'get', 'Method call has been logged');

ok(ref JSON->new->decode($a->getContainers(id=>1)) eq 'HASH', "Show first container command return an hash");


done_testing();