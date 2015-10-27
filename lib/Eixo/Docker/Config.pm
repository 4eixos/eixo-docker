package Eixo::Docker::Config;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(
	AttachStdin => undef,
	AttachStdout => undef,
	AttachStderr => undef,
	Cmd => [],
	Domainname=>undef,
	Entrypoint=>undef,
	Env => undef,
	ExposedPorts => {},
	Hostname => "",
	Image => "",
        Labels => {},
        MacAddress => undef,
        NetworkDisabled => undef,
        OnBuild => undef,
	OpenStdin => undef,
	StdinOnce => undef,
        Tty => undef,
        User => "",
        Volumes => undef,
        WorkingDir => '',
        Mounts => [],



        # Refactorizacion da api para mover a HostConfig os atributos 
        # dependentes dos cgroups
        #Binds=>[],
	#Links=>[],
	#LxcConf=>{},
	#User => "",
	#Memory => 0,
	#MemorySwap=>0,
	#PortSpecs => undef,
	#Tty => undef,
	#Dns => undef,
	#DnsSearch => [],
	#Volumes =>{},
	#WorkingDir => "",
	#MemorySwap=>undef,
	#CpuShares=>undef,
	#Cpuset => '',
	#NetworkDisabled=>undef,
	#OnBuild => undef,
	#PortBindings=>{},
	#ExtraHosts=>undef,
	#CapAdd=>[],
	#CapDrop=>[],
	#Devices=>[],
	#Ulimits=>[{}],
	#SecurityOpt=>[],
	#VolumesFrom => [],
	
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
