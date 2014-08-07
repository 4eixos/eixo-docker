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
	Cpuset => '',
	Domainname=>undef,
	NetworkDisabled=>undef,
	OnBuild => undef,
);

# api_v1.13
# 'Entrypoint' => undef,
# 'User' => '',
# 'ExposedPorts' => {
#                     '8080/tcp' => {}
#                   },
# 'Cmd' => [
#            'node',
#            '/src/index.js'
#          ],
# 'Cpuset' => '',
# 'MemorySwap' => 0,
# 'AttachStdin' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
# 'AttachStderr' => $VAR1->{'Config'}{'AttachStdin'},
# 'CpuShares' => 0,
# 'OpenStdin' => $VAR1->{'Config'}{'AttachStdin'},
# 'Volumes' => undef,
# 'Hostname' => 'my-node-hello',
# 'PortSpecs' => undef,
# 'Tty' => $VAR1->{'Config'}{'AttachStdin'},
# 'Env' => [
#            'HOME=/',
#            'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
#          ],
# 'Image' => 'my-node-hello',
# 'StdinOnce' => $VAR1->{'Config'}{'AttachStdin'},
# 'Domainname' => 'null',
# 'WorkingDir' => '',
# 'Memory' => 0,
# 'NetworkDisabled' => $VAR1->{'State'}{'Paused'},
# 'AttachStdout' => $VAR1->{'Config'}{'AttachStdin'},
# 'OnBuild' => undef


1;
