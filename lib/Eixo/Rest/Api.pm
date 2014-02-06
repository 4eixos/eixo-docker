package Eixo::Rest::Api;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

my $JOB_ID = 1;

has (

	client => undef,

	jobs=>[],

);

sub AUTOLOAD{
	my ($self, @args) = @_;

	my ($method) = our $AUTOLOAD =~ /\:\:(\w+)$/;

	if($method =~ /^get|^post|^patch|^delete|^update/){
		@args = $self->__analyzeRequest($method, @args);
	}

	$self->client->$method(@args);
}


sub DESTROY {}

sub initialize{
	my ($self, $endpoint) = @_;

	$self->client(
		Eixo::Rest::Client->new($endpoint)
	);

	$self;
}

sub produce{
	my ($self, $class, %args) = @_;
	
	$self->__loadProduct($class);

	$class->new(

		api=>$self,

		%args

	)
}

sub newJob{
	my ($self, $request, $id) = @_;

	push @{$self->jobs}, $request;

	$self;
}

sub jobFinished{
	my ($self, $request) = @_;

	$self->jobs([ grep {

		$_ != $request

	} @{$self->jobs} ] );
}

sub waitForJob{
	my ($self, $job_id) = @_;

	$self->waitForJobs($job_id);
	
}

sub waitForJobs{
	my ($self, $id) = @_;

	while(scalar(@{$self->jobs})){

		if($id){
			return unless(scalar(grep { $_->job_id == $id } @{$self->jobs}));
		}

		foreach my $job (@{$self->jobs}){

			$job->process;

			select(undef, undef, undef, 0.05);

		}
	}
}

sub async{
	my ($self, $product, $method, @args) = @_;
	
	my $on_end;

	if(scalar(@args) % 2 != 0){
		$on_end = pop(@args);
	}

	my %args = @args;

	$args{api} = $self;

	$args{PROCESS_DATA} = {

		onSuccess=>$args{onSuccess} || $on_end || die(

			ref($product) . '::' . $method . 'Async: callback is needed'

		),
		
		onError=>$args{onError} || sub {
		
			$product->error(@_)

		},

		onProgress=>$args{onProgress},

		onStart=>$args{onStart}


	};

	$args{__job_id} = $JOB_ID++;

	$product->$method(%args);

	return $args{__job_id};
}

sub __analyzeRequest{
	my ($self, $method, %args) = @_;

	# set client error callback for request if exists
	# Always is defined an error callback by default
	if(exists $args{onError}){
		$self->client->error_callback($args{onError});
	}

	# check args needed
	if($args{needed}){

		foreach (@{$args{needed}}){

			&{$self->client->error_callback}(

				$method, 

				'PARAM_NEEDED', 

				$_ ) unless(exists($args{args}->{$_}));

		}		

	}	

	%{$args{args}}, __callback=>$args{__callback};
}

sub __loadProduct{
	my ($self, $class) = @_;

	$class =~ s/\:\:/\//g;

	require $class . ".pm";
}

1;
