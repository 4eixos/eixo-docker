package Eixo::Docker::Event;

use strict;

sub new{
	
	return bless({

		id=>$_[1],

		status=>$_[2],

		code=>$_[3],
		

	}, $_[0]);
}

sub run{
	my ($self, $event) = @_;

	$self->{code}->($event);
}

1;
