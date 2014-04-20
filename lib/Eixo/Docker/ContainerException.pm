package Eixo::Docker::ContainerException;

use strict;
use warnings;

use Eixo::Rest::BaseException;

use parent qw(Eixo::Rest::BaseException);


my $ERRORS = {
	404 => "No such container",
	400 => "Bad parameter",
	406 => "Impossible to attach (container not running)",
	500 => "Server error",
};

sub ERROR_CODE {
	
	my $self = $_[0];

	my $error_code = $self->args->[0];

	if (exists($ERRORS->{$error_code})){
		$self->error($ERRORS->{$error_code});
		$self->error_details('Error produced in \''.$self->method.'\' api call. Details: '.join(' - ', @{$self->args}));
	}
	else{

		$self->error("Unknown error code");
		$self->error_details("Unknown error code $error_code produced in $self->method")
	}

	
}

