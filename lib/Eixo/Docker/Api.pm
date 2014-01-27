package Eixo::Docker::Api;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;

has (client => undef);

sub initialize{
	my ($self, $endpoint) = @_;

	$self->client(
		Eixo::Rest::Client->new($endpoint)
	);

	$self;
}


1;
