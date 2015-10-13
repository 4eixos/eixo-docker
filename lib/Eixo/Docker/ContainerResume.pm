package Eixo::Docker::ContainerResume;

use strict;
use warnings;

use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

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


