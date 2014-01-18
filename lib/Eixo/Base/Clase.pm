package Eixo::Base::Clase;

use strict;
use warnings;

use Attribute::Handlers;

#
# logger installing code
#
sub __log : ATTR(CODE){

	my ($pkg, $sym, $code, $attr_name, $data) = @_;

	no warnings 'redefine';

	*{$sym} = sub {

		my ($self, @args) = @_;

		$self->logger([$pkg, $data->[0]], \@args);

		$code->($self, @args);
	};

}

sub flog{
	my ($self, $code) = @_;

	unless(ref($code) eq 'CODE'){
		die(ref($self) . '::flog: code ref expected');
	}

	$self->{flog} = $code;
}

sub logger{
	my ($self, @args) = @_;

	return unless($self->{flog});

	$self->{flog}->($self, @args);
}

1;
