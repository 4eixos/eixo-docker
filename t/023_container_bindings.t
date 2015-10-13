use strict;
use t::test_base;

use Eixo::Docker::Api;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $api = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

    my $api_legacy = ($api->__legacy);
    #
    # Set a debugger sub
    #
    $api->client->flog(sub {

	    my ($api_ref, $data, $args) = @_;
        #print "-> Entering in Method '".join("->", @$data)."' with Args (".join(',',@$args).")\n";

    });

    $api->images->create(fromImage=>'ubuntu',tag=>'14.04');

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
            'Binds' => [
                "/mnt:/tmp",
                "/usr:/usr:ro",
            ],
            'PortBindings' => { 
                "5555/tcp" =>  [
                    {
                        "HostIp" =>  "0.0.0.0", 
                        "HostPort" =>  "11044" 
                    }
                ]
            },
        }

    );

    my $c;

    eval{
        $c = $api->containers->create(%h);
    };
    ok(!$@, "New container created");
    print Dumper($@) if($@);
    #
    # test created container and start
    #
    eval {
        $c = $api->containers->getByName($name);
       
    };
    ok(!$@ && ref($c) =~ /^Eixo\:\:Docker\:\:Container/, "getByName working correctly");

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
                },

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
    #print Dumper($port);
    ok(
        $port && ($port->{'5555/tcp'}->[0]->{HostPort} eq "11044"),
        "Internal docker port has been connected to Host port" 
    );

    #print Dumper($c->Mounts);

    ok(
        (
            ($api_legacy)?
            ($c->Volumes->{"/tmp"} eq '/mnt' && $c->Volumes->{'/usr'} eq '/usr'): 
            scalar(@{$c->Mounts}) == 2
        ),

        "Docker volumes attached"
    );

    # sort volumes by source name
    my ($vol1, $vol2) = sort {$a->{Source} cmp $b->{Source}} @{$c->Mounts} if($c->Mounts);

    ok(
        ($api_legacy)?
        ($c->Volumes->{'/tmp'} && $c->VolumesRW->{"/tmp"} == 1):
        (
            $vol1->{Source} eq '/mnt' && 
            $vol1->{Destination} eq '/tmp' &&
            $vol1->{RW} == 1
        ),

        "Volume RW attached as RW"
    );

    ok(
        ($api_legacy)?
        ($c->Volumes->{'/usr'} && $c->VolumesRW->{"/usr"} == 0):
        (
            $vol2->{Source} eq '/usr' &&
            $vol2->{Destination} eq '/usr'&&
            $vol2->{RW} == 0
        ),
        
        "Volumen RO attached as RO"
    );


    $c->kill();

    eval{
        $c->delete(delete_volumes => 1);
    };
    ok(!$@, "Container deleted");

}

done_testing();
