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

sub get{
	my ($self, %args) = @_;

	$self->populate(

		$self->api->getContainers(

			needed=>[qw(id)],

			onError=>sub { $self->error(@_) },

			args=>\%args

		)
	);

	$self->Config(Eixo::Docker::Config->new->populate($self->Config));

	$self;
}

sub getByName {
    my ($self, $name) = @_;
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

	foreach my $r (@{
			$self->api->getContainers(
				onError => sub {$self->error(@_)},
				args => {all => 1})}
			){

		push @$list, Eixo::Docker::ContainerResume->new->populate($r)
	}

	return $list;
	
}

sub create {
	my $self = $_[0];
	my $attrs = $_[1];

    my $args = {};

    if(exists($attrs->{Name})){
        $args->{GET_DATA} = {name => $attrs->{Name}};
        delete($attrs->{Name});
    }

	# validate attrs and fill with default values not set
	my $config = Eixo::Docker::Config->new->populate($attrs);
	
	$args->{action} = 'create';
	$args->{POST_DATA}  = $config;

	my $res = $self->api->postContainers(
			
			onError=>sub { $self->error(@_) },

			args => $args,
	);

    my $id = $res->{Id};

    #return container full loaded
    $self->get(id => $id);

}


sub delete{
	my ($self, %args) = @_;

    if(exists($args{v})){
        $args{GET_DATA} = {v => $args{v}};
        delete($args{v});
    }

	$self->api->deleteContainers(

		needed=>[qw(id)],

		onError=>sub { $self->error(@_) },

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

#sub __errorCodeGetContainers {
#	my ($self, $error_code, $msg) = @_;
#
#	if($error_code eq '404'){
#		die("No such container:$msg");	
#	}
#}


1;
