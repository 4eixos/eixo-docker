package Eixo::Docker::HostConfig;

use strict;
use warnings;

use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(
    Binds => undef,             #["/tmp:/tmp"]
    LxcConf => undef,           #{"lxc.utsname":"docker"},
    PortBindings => undef,      # { "22/tcp": [{ "HostPort": "11022" }] },
    PublishAllPorts => undef,   # false,
    Privileged => undef,        #false
    NetworkMode => '',
    ContainerIDFile => '',
    DnsSearch => undef,
    Links => undef,
    VolumesFrom => undef,
    Dns => undef
);


# api#v1.13
# 'Binds' => undef,
# 'NetworkMode' => '',
# 'Privileged' => $VAR1->{'State'}{'Paused'},
# 'ContainerIDFile' => '',
# 'DnsSearch' => undef,
# 'Links' => undef,
# 'LxcConf' => undef,
# 'PortBindings' => undef,
# 'VolumesFrom' => undef,
# 'PublishAllPorts' => $VAR1->{'State'}{'Paused'},
# 'Dns' => undef
