package Eixo::Docker::ImageResume;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(

    RepoTags => [],
    Id => undef,
    Created=>undef,
    CreatedBy => undef,
    Size=>undef,
    VirtualSize=>undef,
    ParentId=>undef,

);

1;
