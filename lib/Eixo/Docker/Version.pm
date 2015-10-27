package Eixo::Docker::Version;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(
    
    Version 	=> "",
    Os		=> undef,
    KernelVersion	=> undef,
    GoVersion	=> undef,
    GitCommit	=> undef,
    Arch		=> undef,
    ApiVersion	=> undef, 
    Experimental	=> undef, 
);


sub get{
	my ($self, %args) = @_;

	$args{__implicit_format} = 1;

	$self->api->getVersion(

		args=>\%args,
		
		__callback=> sub {

			$self->populate($_[0]);
		}

	);

	$self;
}



1;
