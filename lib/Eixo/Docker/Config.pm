package Eixo::Docker::Config;

use strict;
use warnings;

use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(

	Hostname => "",
	User => "",
	Memory => 0,
	AttachStdin => undef,
	AttachStdout => undef,
	AttachStderr => undef,
	PortSpecs => undef,
	Tty => undef,
	OpenStdin => undef,
	StdinOnce => undef,
	Env => undef,
	Cmd => [],
	Dns => undef,
	Image => "",
	Volumes =>{},
	VolumesFrom => "",
	WorkingDir => "",
	ExposedPorts => {},
	Entrypoint=>[],
	MemorySwap=>undef,
	CpuShares=>undef,
	Domainname=>undef,
	NetworkDisabled=>undef,
	OnBuild => undef,
);

1;
