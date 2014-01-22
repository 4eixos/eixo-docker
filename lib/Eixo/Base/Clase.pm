package Eixo::Base::Clase;

use strict;
use warnings;

use Attribute::Handlers;

use base qw(Class::Accessor);

sub new{
	my ($clase, @args) = @_;

	my $self = bless({}, $clase);

	my %attrs = $self->attrs;

	$self->mk_accessors(keys(%attrs));

	$self->$_($attrs{$_}) foreach(keys(%attrs));

	$self->initialize(@args) if($self->can('initialize'));

	$self;
}

#
# Methods
#
sub methods{
	my ($self, $class, $nested) = @_;

	$class = $class || ref($self) || $self;

	no strict 'refs';

	my @methods = grep { defined(&{$class . '::' . $_} ) } keys(%{$class . '::'});

	push @methods, $self->methods($_, 1) foreach(@{ $class .'::ISA' } );


	unless($nested){

		my %s;

		$s{$_}++ foreach( map { $_ =~ s/.+\:\://; $_ } @methods);

		return keys(%s);
	}

	@methods;
	
}

#
# logger installing code
#
sub __log : ATTR(CODE){

	my ($pkg, $sym, $code, $attr_name, $data) = @_;

	no warnings 'redefine';

	*{$sym} = sub {

		my ($self, @args) = @_;

		$self->logger([$pkg, *{$sym}{NAME}], \@args);

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
