package Eixo::Docker::Container;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

use Eixo::Docker::Config;

has(

	Config => {},
	Volumes => {},
	Image => {},
	ID => undef,
	Config => {},
	NetworkSettings => {},
	VolumesRW => {},
	HostsPath => '',
	State => '',
	HostnamePath => '',
	Args => [],
	HostConfig => {},
	ResolvConfPath => '',
	Path => '',
	Created => '',
	Driver => '',
	Name => '',
	

);

sub get{
	my ($self, %args) = @_;

	$self->populate(

		$self->api->getContainers(

			needed=>[qw(id)],

			onError=>sub { $self->error(@_) },

			args=>\%args

		)
	);

	$self->Config(Eixo::Docker::Config->new->populate($self->Config));

	$self;
}




1;
