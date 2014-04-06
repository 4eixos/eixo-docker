package Eixo::Docker::Api;

use strict;
use warnings;

use parent qw(Eixo::Rest::Api);

sub containers {
	$_[0]->produce('Eixo::Docker::Container');
}

sub images {
	$_[0]->produce('Eixo::Docker::Image');
}


1;
