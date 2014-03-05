package Eixo::Rest::Product;

use strict;
use Eixo::Base::Clase;
use Eixo::Rest::Client;
use Eixo::Rest::BaseException;

has (api => undef);

sub AUTOLOAD{
	my ($self, @args) = @_;

	#
	# Searching for meaningful verbs
	#	
	my ($method) = our $AUTOLOAD =~ /\:\:(\w+)$/;

	if(my ($original_method) = $method =~ /(\w+)Async$/){
	
		unless($self->can($original_method)){
			die(ref($self) . '::UNKONW_METHOD: ' . $original_method + ' async') 	
		}

		$self->api->async(

			$self,

			$original_method,

			@args,

		);
	}
	# else{

	# 	$self->api->sync(

	# 		$self,

	# 		$method,

	# 		@args
	# 	);
	# }
}

sub DESTROY{}

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

sub NOT_SERIALIZE{
	return qw(api);
}

sub is_serializable{
	my ($self,$attribute) = @_;

	return undef if(grep {$attribute eq $_} $self->NOT_SERIALIZE);

	return 1;
}

sub TO_JSON {
	my $self = $_[0];

	return {map {$_ => $self->$_} grep {$self->is_serializable($_)} keys(%$self)};
}

1;
