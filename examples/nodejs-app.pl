use strict;
use Data::Dumper;
use Eixo::Docker::Api;
  
my $a = Eixo::Docker::Api->new('http://127.0.0.1:4243');

# First clone in a local path, the nodejs app code repo (https://github.com/enokd/docker-node-hello.git). 
# For example in '/tmp/docker-node-hello'.

# Build an image, from a Dockerfile. It needs to pass a directory, because
# must contains files you want to ADD to image, and all the directory will be tarred and sended to api
# It returns an Eixo::Docker::Image object

eval{

    my $image = $a->images->build_from_dir(
        t => "my-node-hello",
        DIR => "/tmp/docker-node-hello",
        onProgress => sub {print $_[0]."\n"},
    #     onSuccess => sub {print "finish\n"},
    );
    
    #'my-node-hello' image must be listed 
    print Dumper($a->images->getAll);
    print "Press any key ...\n";
    <STDIN>;
    
    # Now you can create the docker container from this image
    # to see all available params
    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.13/#create-a-container
    
    my $c = $a->containers->create(
        Hostname => 'my-node-hello',
        Image => "my-node-hello",
        Name => "node_hello_01",
        NetworkDisabled => "false",
        ExposedPorts => {
    	    "8080/tcp" =>  {}
        },
    );
    
    
    # Using docker api you must start the container once created
    # and other options can be specified in start action (for example de ports in host to attach to container exposed ports)
    
    print "Starting container...\n";
    $c->start(
        "PortBindings" => { "8080/tcp" =>  [{"HostIp" =>  "0.0.0.0", "HostPort" =>  "49160" }] },
    
    );

    print "container node_hello_01 created and started\n";
    print "Press any key ...\n";
    <STDIN>;
    
    print "Checking container logs\n";
    # To print app output (docker logs)
    my $output_callback = $c->attach(
        stdout=>1,
        stderr => 1,
        stdin=>0,
        stream=>0,
        logs => 1,
    );
    
    print '--> '.$output_callback->();
};
print Dumper($@) if($@);
