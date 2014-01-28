package Eixo::Rest::BaseException;

use strict;
use Eixo::Base::Clase;

has(
	method => '',
	reason => '',
	args => [],
	error => '',
	error_details => '',
);

sub initialize {
	my ($self, %args) = @_;

	$self->method($args{method});
	$self->reason($args{reason});
	chomp(@{$args{args}});
	$self->args($args{args});

	$self->__generateError();

	$self;
}


sub raise {

	die($_[0]);
}


sub __generateError {

	my $self = $_[0];

	if($self->can($self->reason)){
		my $f = $self->reason;
		$self->$f();
	}
	else{
		$self->error("Unknown error");
		$self->error_details('Unknown error in method '.$self->method.' with reason '.$self->reason);
	}

}


sub PARAM_NEEDED {
	my $self = $_[0];
	$self->error("Param needed");
	$self->error_details("Method ".$self->method. " needs ".$self->args->[0]);
}

1;
