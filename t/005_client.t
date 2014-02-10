use strict;
use warnings;

use Test::More;
use Data::Dumper;
use JSON;

use lib './lib';

use Eixo::Rest::Client;
#use_ok "Eixo::Rest::Client";

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
ok($@ =~ /UNKNOW METHOD/, 'Non-existent Client methods launch exception');

my $process_data = {
    onSuccess => sub {return $_[0]},
};
my $callback = sub {$_[0]};

my $h = $a->getContainers(
    GET_DATA => {all => 1},
    PROCESS_DATA => $process_data,
    __callback => $callback
);
diag "Get all containers returns ". Dumper($h);

ok(
	ref $h eq "ARRAY", 
	"Testing containers list command return an array"
);

ok($calls[0] eq 'get', 'Method call has been logged');


done_testing();
