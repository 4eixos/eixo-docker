use t::test_base;

use Eixo::Docker::Api;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

    #
    # Set a debugger sub
    #
    $a->client->flog(sub {

	    my ($api_ref, $data, $args) = @_;
	    #print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

    });

    my $name = "testing".int(rand(1000));
    my %h = (

        Hostname => 'test',
        Cmd => ["nc", "-l", '0.0.0.0', '5555'],
        Image => "ubuntu:14.04",
        Name => $name,
        ExposedPorts => {
            "5555/tcp" =>  {}
        },

        NetworkDisabled => \0,

        HostConfig => {
            "Binds" => [
                "/mnt:/tmp",
                "/usr:/usr:ro",
            ],
            "PortBindings" => { 
                "5555/tcp" =>  [
                    {
                        "HostIp" =>  "0.0.0.0", 
                        "HostPort" =>  "11044" 
                    }
                ]
            },
            "PublishAllPorts" => \0,
            "Privileged" => \0,
        }

    );

    eval{
        $c = $a->containers->create(%h);
    };
    ok(!$@, "New container created");
    print Dumper($@) if($@);
    #
    # test created container and start
    #
    eval {
        $c = $a->containers->getByName($name);
       
    };
    ok(!$@ && ref($c) eq "Eixo::Docker::Container", "getByName working correctly");

    eval{
        ok( 
            $c->start(
            
                "PortBindings" => { 
                    "5555/tcp" =>  [
                        {
                            "HostIp" =>  "0.0.0.0", 
                            "HostPort" =>  "11044" 
                        }
                    ]
                }
            ),
            "The container starts"
        )
    };
    die Dumper($@) if($@);

    # check NetworkSettings (generated dinamically)
    #"NetworkSettings": {
    #    "IPAddress": "172.17.0.2",
    #    "IPPrefixLen": 16,
    #    "Gateway": "172.17.42.1",
    #    "Bridge": "docker0",
    #    "PortMapping": null,
    #    "Ports": {
    #        "5555/tcp": [
    #            {
    #                "HostIp": "0.0.0.0",
    #                "HostPort": "11022"
    #            }
    #        ]
    #    }
    #}


    $c->get();
    my $port = $c->NetworkSettings->{Ports};
    print Dumper($port);
    ok(
        $port && ($port->{'5555/tcp'}->[0]->{HostPort} eq "11044"),
        "Internal docker port has been connected to Host port" 
    );

    print Dumper($c->Volumes);

    ok(
        ($c->Volumes->{"/tmp"} eq '/mnt' && $c->Volumes->{'/usr'} eq '/usr'),

        "Docker volumes attached"
    );

    ok(
        $c->Volumes->{'/tmp'} && $c->VolumesRW->{"/tmp"} == 1,
        "Volume RW attached as RW"
    );

    ok(
        $c->Volumes->{'/usr'} && $c->VolumesRW->{"/usr"} == 0,
        
        "Volumen RO attached as RO"
    );



    $c->kill();

    eval{
        $c->delete(delete_volumes => 1);
    };
    ok(!$@, "Container deleted");

}

done_testing();
