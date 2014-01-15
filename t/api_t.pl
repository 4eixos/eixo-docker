use strict;
use warnings;

use Test::More;
use Data::Dumper;
use JSON;

use lib './lib';

use Eixo::Docker::Api;

# set log function
# Eixo::Docker::Base::stashSet("f_log", sub {print join("\n",@_)});


my $a = Eixo::Docker::Api->new("http://localhost:4243");

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

ok(ref JSON->new->decode($a->getContainers(id=>1)) eq 'HASH', "Show first container command return an hash");

done_testing();
