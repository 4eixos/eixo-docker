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
	
	format=>'json'

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
	
		$self->callback->($self->unmarshall($response)),

	);
}

sub error{
	my ($self, $response) = @_;

	&{$self->onError}($response);
	# 	$response->code,
	# 	$response->content,
	# );

}

sub progress{
    my ($self, $chunk, $req) = @_;

    $self->onProgress->($chunk, $req) if($self->onProgress);
}   

sub process {die ref($_[0]) . "::process: MUST BE DEFINED"}

sub send {die ref($_[0]) . "::send: MUST BE DEFINED"}

sub unmarshall{
	my ($self, $response) = @_;

	my $content = $response->content;

	if($self->format eq 'json'){

		return JSON->new->decode($content || '{}')
	}
	else{
		return $content;
	}
}



1;
