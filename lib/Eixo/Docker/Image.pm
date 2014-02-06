package Eixo::Docker::Image;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

use Eixo::Docker::Config;
use Eixo::Docker::ImageResume;

has(
    id => undef,			
    parent => undef,		
    created => undef,	
    container => undef, 
    container_config => {},
    Size => 0, 		
    config => {},
    comment => undef,
    architecture => undef,
    docker_version => undef,
    os => undef,

);



sub initialize{
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

	$args{id} = $self->id if($self->id);

	$self->api->getImages(

		needed=>[qw(id)],

		args=>\%args,

		__callback=>sub {

			$self->populate($_[0]);
			
			if(my %h = %{$self->container_config}){
				$self->container_config(Eixo::Docker::Config->new(%h));
			}

			if(my %h = %{$self->config}){
				$self->config(Eixo::Docker::Config->new(%h));
			}

			$self;

		}
	);

	#$self;

}

sub inspect{
	my ($self, %args) = @_;

	$args{id} = $self->id if($self->id);
	
	$args{action} = 'json';
	
	$self->api->getImages(

		needed=>[qw(id)],

		args=>\%args,

		__callback=>sub {

		}

	);

}

sub getAll{
	my ($self, %args) = @_;

	my $list = [];

	$args{all} = 1;

	#foreach my $i (@{$self->api->getImages(args=>\%args)}){
	#	push @$list, $self->api->images->populate($i)
	#}

	$self->api->getImages(

		args=>\%args, 

		get_data => [qw(all)],

		__callback=>sub {

 			foreach(@{$_[0]}){
				# push @$list, $self->api->images->populate($_);
				push @$list, Eixo::Docker::ImageResume->new(%$_);
			}

			$list;
		}

	);

	$list;

}

sub create{
	my ($self, %args) = @_;


	# actually, only fromImage it's supported

	my $image = $args{fromImage};

	$args{action} = 'create';

	$args{__format} = 'RAW';

	$self->api->postImages(

		needed=>[qw(fromImage)],

		args=>\%args,

		get_params=>[qw(fromImage repo tag registry)],

		__callback=>sub {

			$self->get(id=>$image);

			return $self;
		}
	);

	#$self;
}

sub insertFile{
	my ($self, %args) = @_;
	
	$args{action} = 'insert';

	$args{__format} = 'RAW';

	$self->api->postImages(

		needed=>[qw(url path id)],

		args=>\%args,

		get_params=>[qw(url path)],

		__callback=>sub {

			#
			# Take the last id and use it to get the new image
			#
			$_[0] =~ /\"\id\"\:\"([^"]+)\"\}$/;

			$self->api->images->get(id=>substr($1, 0, 12));			
		
		},
	

	);
}


sub delete{
	my ($self, %args) = @_;

	$args{id} = $self->id unless($args{id});

	$self->api->deleteImages(

		needed=>[qw(id)],
		
		args=>\%args

	);
}

1;
