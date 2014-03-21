use strict;
use warnings;

use 5.008001;
use Module::Build;

my $builder = Module::Build->new(
    module_name => "Eixo::Docker",

    dist_abstract => "Suite of modules to interact with Docker",

    dist_author => [
        'Javier Gómez <alambike@gmail.com>', 
        'Francisco Maseda <frmadem@gmail.com>',
    ],

    license => "apache",

    requires => {
        'perl' => 5.008001,
        'JSON' => 2.50,
        'LWP::UserAgent' => 5.0,
        'Net::HTTP' => 6.06,
    },

    recommends => {
        'HTTP::Server::Simple::CGI' => 0
    },

    create_makefile_pl => "traditional",

);

$builder->create_build_script;



