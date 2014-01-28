package Eixo::Docker::ContainerResume;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(

	Id => '',
	Image => '',
	Command => '',
	Created => 0,
	Status => '',
	Ports => [],
	SizeRw => 0,
	SizeRootFs => 0,
	Names => []
);


