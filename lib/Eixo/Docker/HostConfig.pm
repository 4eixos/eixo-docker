package Eixo::Docker::HostConfig;

use strict;
use warnings;

use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(
    Binds => [],             #["/tmp:/tmp"]
    LxcConf => [],           #{"lxc.utsname":"docker"},
    PortBindings => undef,      # { "22/tcp": [{ "HostPort": "11022" }] },
    PublishAllPorts => undef,   # false,
    Privileged => undef,        #false
    NetworkMode => '',
    ContainerIDFile => '',
    VolumesFrom => undef,
    Dns => [],

    Memory => 0,
    MemorySwap => -1,
    CpuShares => 0,
    CpuPeriod => 0,
    CpusetCpus => "",
    CpusetMems => "",
    CpuQuota => 0,
    BlkioWeight => 0,
    OomKillDisable => undef,
    MemorySwappiness => -1,
    PortBindings => {},
    Links => [],
    PublishAllPorts => undef,
    DnsSearch => [],
    ExtraHosts => [],
    Devices => [],
    IpcMode => "",
    PidMode => "",
    UTSMode => "",
    CapAdd => [],
    CapDrop => [],
    GroupAdd => undef,
    RestartPolicy => {
       Name => "no",
       MaximumRetryCount => 0
    },
    SecurityOpt => undef,
    ReadonlyRootfs => undef,
    Ulimits => undef,
    LogConfig => {
       Type => "json-file",
       Config => {}
    },
    CgroupParent => "",
    ConsoleSize => [
       0,
       0
    ]
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
