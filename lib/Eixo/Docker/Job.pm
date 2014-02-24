package Eixo::Docker::Job;

use Eixo::Base::Clase;

has (
    id  => 0,
    params => undef,
    results => undef,
    status => 'NEW',
);

1;