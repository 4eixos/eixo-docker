package AA;
use t::test_base;

BEGIN{use_ok("Eixo::Base::Clase")}


use parent qw(Eixo::Base::Clase);

has (

	n => 55,
	o => 'aaa',
	p => {},
	a => [],
	nulo=>undef,
	vacio=>0,
	nada=>''

);

use strict;
use warnings;

use Test::More;
use Data::Dumper;
use JSON;

my $aa = AA->new;

my @m = qw(n o p a);

is(scalar(@m), scalar(grep { $aa->can($_)} @m), 'Accessors have been created');

is($aa->n, 55, 'Values initialize well (0)');
is($aa->o, 'aaa', 'Values initialize well (1)');
is(ref $aa->p, 'HASH', 'Values initialize well (2)');
is(ref $aa->a, 'ARRAY', 'Values initialize well (3)');


done_testing();
