package Eixo::Rest::Product;

use strict;
use Eixo::Base::Clase;
use Eixo::Rest::Client;
use Eixo::Rest::BaseException;

has (api => undef);

sub populate{
	my ($self, $values) = @_;

	$self->$_($values->{$_}) foreach(keys(%$values));

	$self;
}



sub error{
	my ($self, $method, $reason, @args) = @_;

	if($self->can("__error")){
		$self->__error($method, $reason, @args);
	}
	else{
		Eixo::Rest::BaseException->new(
			method => $method,
			reason => $reason,
			args => \@args,
		)->raise();
	}
}

1;
