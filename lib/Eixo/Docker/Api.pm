package Eixo::Docker::Api;

use strict;
#use warnings;

use lib '/tmp/Eixo-Docker/lib';

use parent qw(Eixo::Base::Clase);


use Eixo::Docker::Client;
use Attribute::Handlers;

sub attrs{

	client=>undef,
}

sub initialize{
	my ($self, $endpoint) = @_;

	$self->client(
		Eixo::Docker::Client->new($endpoint)
	);

	$self;
}

#my $t = __PACKAGE__->new('cajo en ');

#use Data::Dumper; die(Dumper($t));

1;
