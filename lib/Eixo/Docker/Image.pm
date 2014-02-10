package Eixo::Docker::Image;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

use Eixo::Docker::Config;
use Eixo::Docker::ImageResume;

has(
	id => undef,					#"id":"b750fe79269d2ec9a3c593ef05b4332b1d1a02a62b4accb2c21d589ff2f5f2dc",
    parent => undef,				#"parent":"27cf784147099545",
    created => undef,				#"created":"2013-03-23T22:24:18.818426-07:00",
    container => undef, 			#"container":"3d67245a8d72ecf13f33dffac9f79dcdf70f75acb84d308770391510e0c23ad0",
    container_config => {},			#"container_config":
    Size => 0, 						#"Size": 6824592
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

		}
	);

	$self;

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

	$args{fromImage} || $args{fromSrc} || $self->api->client->error_callback->(

		'ImageCreate',

		'PARAM_NEEDED',

		'fromImage | fromSrc'

	);

	$args{action} = 'create';

	$args{GET_DATA} = { map { $_ => $args{$_} } qw(fromImage fromSrc) }; 

	$self->api->postImages(

	#	needed=>[qw(repo tag registry)],

		args=>\%args,

		__callback=>$args{__callback}
	);

	#$self;
}

1;
