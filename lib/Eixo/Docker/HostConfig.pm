package Eixo::Docker::HostConfig;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

has(
    Binds => [],
    PortBindings => {},
    BlkioWeight => 0,
    CapAdd => undef,
    CapDrop => undef,
    ContainerIDFile => "",
    CpusetCpus => "",
    CpusetMems =>"",
    CpuShares => 0,
    CpuPeriod => 100000,
    CpuQuota => 0,
    Devices => [],
    Dns => undef,
    DnsSearch => undef,
    ExtraHosts => undef,
    IpcMode => "",
    Links => undef,
    LxcConf => [],
    Memory => 0,
    MemorySwap => 0,
    MemorySwappiness => -1,
    OomKillDisable => undef,
    NetworkMode => "bridge",
    Privileged => undef,
    ReadonlyRootfs => undef,
    PublishAllPorts => undef,
    RestartPolicy => {
        MaximumRetryCount => 2,
        Name => "on-failure"
    },
    LogConfig => {
        Config => {},
        Type => "json-file"
    },
    SecurityOpt => undef,
    VolumesFrom => undef,
    Ulimits => [],
    CgroupParent => "",
    ConsoleSize => [0,0],
    PidMode => "",
    UTSMode => "",
    GroupAdd => undef,
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
