package Eixo::Docker::Container;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

use Eixo::Docker::Config;
use Eixo::Docker::ContainerResume;
use Eixo::Docker::ContainerException;

has(

	Config => {},
	Volumes => {},
	Image => {},
	ID => undef,
	Config => {},
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
	

);

sub initialize {
    my $self = $_[0];

    # set default Docker::Rest::Client error callback 
    # to call when API response error is received
    $self->api->client->error_callback(
        sub { $self->error(@_) }    
    );

    $self;
}

sub get{
	my ($self, %args) = @_;

	$self->populate(

		$self->api->getContainers(

			needed=>[qw(id)],

			args=>\%args

		)
	);

    # load config obj replacing config hash 
	$self->Config(Eixo::Docker::Config->new->populate($self->Config));

	$self;
}


sub getByName {
    my ($self, $name) = @_;

    return undef unless($name);

    $name = '/'.$name unless($name =~ /^\//);
    
    #get all containers
    my $list = $self->getAll();
    foreach my $c (@$list){
        return $self->get(id => $c->Id) if (grep {$name eq $_} @{$c->Names});
    }
}


sub getAll {

	my $self = $_[0];

	my $list  = [];

    my $args = {
        GET_DATA => {
            all => 1
        }
    };

	foreach my $r (@{$self->api->getContainers(args => $args)}){

		push @$list, Eixo::Docker::ContainerResume->new->populate($r)
	}

	return $list;
	
}


sub create {
	my ($self , %attrs) = @_;

    my $args = {};

    if(exists($attrs{Name})){
        $args->{GET_DATA} = {name => $attrs{Name}};
        delete($attrs{Name});
    }

	# validate attrs and initialize default values not setted
	my $config = Eixo::Docker::Config->new->populate(\%attrs);
	
	$args->{action} = 'create';
	$args->{POST_DATA}  = $config;

	my $res = $self->api->postContainers(
			args => $args,
	);

    my $id = $res->{Id};

    #return container fully loaded
    $self->get(id => $id);

}


sub delete{
	my ($self, %args) = @_;

    my $delete_volumes = (exists($args{delete_volumes}))? 
                            $args{delete_volumes}:
                            (exists($args{v}))? 
                                $args{v} :0;
    


    $args{GET_DATA} = {
            v => $delete_volumes
    };

	$self->api->deleteContainers(
		needed=>[qw(id)],
        args => \%args,
    );

}


sub __error {
	my ($self, $method, $reason,@args) = @_;

	Eixo::Docker::ContainerException->new(
		method => $method, 
		reason => $reason, 
		args => \@args
	)->raise();

}


1;
