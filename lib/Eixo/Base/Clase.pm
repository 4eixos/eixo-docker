package Eixo::Base::Clase;

use Attribute::Handlers;
use strict;
use warnings;


use parent qw(Exporter);

our @EXPORT = qw(has);


sub import{
	no strict "refs";
	my $caller = caller;
	push @{$caller . '::ISA'}, "Eixo::Base::Clase";
	*{$caller . '::has'} = \&has;
}

sub has{
	my (%attributes) = @_;

	my $class = (caller(0))[0];

	no strict 'refs';
	
	foreach my $attribute (keys(%attributes)){
			
		unless(defined(&{$class . '::' . $attribute})){

			*{$class . '::' . $attribute} = sub {

				my ($self, $value)  = @_;

				if(defined($value)){
					
					$self->{$attribute} = $value;
					
					$self;
				}
				else{
					$self->{$attribute};
				}	

			};
		}
	}

	*{$class . '::' . '__initialize'} = sub {

		my ($self) = @_;

		foreach(keys %attributes){
			$self->{$_} = $attributes{$_};
		}
	};  
}

sub new{
	my ($clase, @args) = @_;

	my $self = bless({}, $clase);

	# 3 initilization forms with defined precedence

	# initialize attributes with default values from 'has' hash
	$self->__initialize;

	# if new is called with initialization values (not recommended)
	if(@args % 2 == 0){

		my %args = @args;

		foreach(keys(%args)){

			$self->$_($args{$_}) if($self->can($_));

		}
	}

	# if class has initialize method (recommended)
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
sub Log :ATTR(CODE){

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
