package Eixo::Rest::Product;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;

has (api => undef);

sub populate{
	my ($self, $values) = @_;

	$self->$_($values->{$_}) foreach(keys(%$values));

	$self;
}

sub error{
	my ($self, $method, $reason, @args) = @_;

	if($reason eq 'PARAM_NEEDED'){
		die($method . ' needs ' . $args[0]);
	}
	elsif($reason eq 'ERROR_CODE'){
	
		my $error_method = '__errorCode' . ucfirst($method);

		if($self->can($error_method)){
			$self->$error_method(@args);
		}
		else{
			die($method . " : error code " . $args[0]);
		}
	}
	else{
		die('Unknow error: ' . $reason);
	}
}

1;
