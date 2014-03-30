use strict;
use warnings;

use 5.008001;
use Module::Build;

my $builder = Module::Build->new(
    module_name => "Eixo::Docker",

    dist_abstract => "Suite of Perl modules to interact with Docker",

    dist_author => [
        'Javier Gomez <alambike@gmail.com>', 
        'Francisco Maseda <frmadem@gmail.com>',
    ],

    license => "apache",

    requires => {
        'perl' => 5.008001,
        'JSON' => 2.50,
        'Net::HTTP' => 6.06,
        'Eixo::Base' => 1.00,
        'Eixo::Rest' => 1.00,
    },

    recommends => {
        'HTTP::Server::Simple::CGI' => 0
    },

);

$builder->create_build_script;



