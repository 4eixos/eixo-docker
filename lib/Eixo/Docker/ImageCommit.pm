package Eixo::Docker::ImageCommit;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(

    Tags => [],
    Id => undef,
    Created=>undef,
    CreatedBy=>undef,
    Size=>undef,
);
