package Eixo::Rest::Request;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

has (
	callback=>undef,

	onProgress => undef,
	onSuccess =>  undef,
	onError => undef,
	onStart => undef,
	

);

sub start{
	my ($self) = @_;

	if($self->onStart){
		$self->onStart->();
	}
}

sub end{

	my ($self, $response) = @_;

	&{$self->onSuccess}(
	
		$self->callback->(JSON->new->decode($response->content || '{}')),

		# $_[1]
	);
}

sub error{
	my ($self, $response) = @_;

	&{$self->onError}($response);
	# 	$response->code,
	# 	$response->content,
	# );

}

sub progress {die "MUST BE DEFINED"}
sub send {die "MUST BE DEFINED"}

1;