package Eixo::Docker::Api;

use strict;
use warnings;

use parent qw(Eixo::Rest::Api);

use Eixo::Docker::EventRegister;

sub containers {
	$_[0]->produce('Eixo::Docker::Container');
}

sub images {
	$_[0]->produce('Eixo::Docker::Image');
}

sub version{
	$_[0]->produce('Eixo::Docker::Version');
}

sub events{
	$_[0]->produce('Eixo::Docker::Events');
}

sub eventPool{
	my ($self) = @_;
	
	return $self->{ev} if($self->{ev});

	$self->{ev} = Eixo::Docker::EventRegister->new(

		$self,

		
	);
}

1;
