package Eixo::Docker::ImageCommit;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(

    Tags => [],
    Id => undef,
    Created=>undef,
    CreatedBy=>undef,
    Size=>undef,
);
