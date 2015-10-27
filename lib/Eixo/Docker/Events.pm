package Eixo::Docker::Events;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

use JSON;

my $DEFAULT_TIMEOUT = 30;

has(

	Events=>[]    

);

sub initialize {
    my ($self, @args) = @_;

    $self->SUPER::initialize(@args);

    # set default Docker::Rest::Client error callback 
    # to call when API response error is received
    $self->api->client->error_callback(
        sub { $self->error(@_) }    
    );

    $self;
}

sub get{
	my ($self, %args) = @_;

	$args{__implicit_format} = 'RAW';
	$args{__format} = 'RAW';

	if(exists($args{filters})){

		die(ref($self) . '::get: a HASH was expected in filters') unless(ref($args{filters}) eq 'HASH');

		foreach(keys(%{$args{filters}})){

			$args{filters}->{$_} = [$args{filters}->{$_}] unless(ref($args{filters}->{$_}) eq 'ARRAY');

		}

		$args{filters} = JSON->new->encode($args{filters});

	}
	$self->api->getEvents(

		get_params=>[qw(filters since until)],

		args=>\%args,
		
		__callback => sub {

			my ($events, $request) = @_;

			my $j = JSON->new;

			push @{$self->{Events}}, map { $j->decode($_) } split(/\n/, $events);

		},
	);

	$self;
}

1;
