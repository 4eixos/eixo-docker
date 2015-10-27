package Eixo::Docker::ContainerResume;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(

    Id => '',
    Names => [],
    Image => '',
    Command => '',
    Created => 0,
    Status => '',
    Ports => [],
    Labels => {},
    SizeRw => 0,
    SizeRootFs => 0,
);


