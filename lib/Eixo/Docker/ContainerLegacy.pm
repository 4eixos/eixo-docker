package Eixo::Docker::ContainerLegacy;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Docker::Container);

has(

        Config => {},
        Volumes => {},
        Image => {},
        Id => undef, # new ID attribute from api#v1.12
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
    
        ProcessLabel => '',
        MountLabel => '',
        ExecDriver => '',
    
);

1;
