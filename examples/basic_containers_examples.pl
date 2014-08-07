use lib '/tmp/eixo-docker/lib';

use strict;
use Data::Dumper;

use Eixo::Docker::Api;

my $a = Eixo::Docker::Api->new("http://localhost:4243"); 

#
# container
#

# getAll
my $lista = $a->containers->getAll(); 


# get (by id)
my $c = $a->container->get(id => '340f03a2c2cfxx');


# getByName
my $c = $a->containers->getByName("testing123");

# create
# to see all available params 
# http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/#create-a-container
my $c = $a->container->create(

	Hostname => 'test',
	Memory	 => 128,
	Cmd => ["ls","-l"],
	Image => "ubuntu",
	Name => "testing123"
);

