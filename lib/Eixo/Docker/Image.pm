package Eixo::Docker::Image;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

has(

	RepoTags => [],
	Id => undef,
	Created=>undef,
	Size=>undef,
	VirtualSize=>undef,
	ParentId=>undef,

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

	$args{id} = $self->Id if($self->Id);

	$self->api->getImages(

		needed=>[qw(id)],

		args=>\%args,

		__callback=>sub {

			$self->populate($_[0]);

		}
	);

}

sub getAll{
	my ($self, %args) = @_;

	my $list = [];

	$args{GET_DATA} = { 
		all=>1
	};

	#foreach my $i (@{$self->api->getImages(args=>\%args)}){
	#	push @$list, $self->api->images->populate($i)
	#}

	$self->api->getImages(

		args=>\%args, 

		__callback=>sub {

 			foreach(@{$_[0]}){
				push @$list, $self->api->images->populate($_);
			}

			$list;
		}

	);

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
