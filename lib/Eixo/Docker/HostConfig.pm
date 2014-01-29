package Eixo::Docker::HostConfig;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(
    Binds => undef,             #["/tmp:/tmp"]
    LxcConf => undef,           #{"lxc.utsname":"docker"},
    PortBindings => undef,      # { "22/tcp": [{ "HostPort": "11022" }] },
    PublishAllPorts => undef,   # false,
    Privileged => undef,        #false
);


