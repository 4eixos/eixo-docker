package Eixo::Rest::Api;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;

has (client => undef);

sub AUTOLOAD{
	my ($self, @args) = @_;

	my ($method) = our $AUTOLOAD =~ /\:\:(\w+)$/;

	if($method =~ /^get|^post|^patch|^delete|^update/){
		@args = $self->__analyzeRequest($method, @args);
	}

	$self->client->$method(@args);
}

sub initialize{
	my ($self, $endpoint) = @_;

	$self->client(
		Eixo::Rest::Client->new($endpoint)
	);

	$self;
}

sub produce{
	my ($self, $class, %args) = @_;
	
	$self->__loadProduct($class);

	$class->new(

		api=>$self,

		%args

	)
}

sub __analyzeRequest{
	my ($self, $method, %args) = @_;

	my $f_error = $args{onError} || sub {
		die($_[0] . ' : ' . $_[1]);
	};

	if($args{needed}){

		foreach (@{$args{needed}}){

		 	&$f_error($method, 'PARAM_NEEDED', $_) unless(exists($args{args}->{$_}));

		}		

	}

	%{$args{args}};
}

sub __loadProduct{
	my ($self, $class) = @_;

	$class =~ s/\:\:/\//g;

	require $class . ".pm";
}

1;
