package Eixo::Rest::RequestAsync;

use strict;

use threads;
use Thread::Queue;

use JSON -convert_blessed_universally;

# use Eixo::Base::Clase;
use Eixo::Rest::Request;
use parent qw(Eixo::Rest::Request);

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

use Eixo::Rest::RequestAsyncThread;

has (

	job_id=>undef,
	api=>undef,

	# callback=>undef,

	# onProgress => undef,
	# onSuccess =>  undef,
	# onError => undef,
	# onStart => undef,
	
	thread=>undef,
	queue=>undef,

);

# sub start{
# 	my ($self) = @_;

# 	if($self->onStart){
# 		$self->onStart->();
# 	}
# }

# sub end{

# 	my ($self, $response) = @_;

# 	$self->api->jobFinished($self);

# 	&{$self->onSuccess}(
	
# 		$self->callback->(JSON->new->decode($reponse->content || '{}')),

# 		# $_[1]
# 	);
# }

# sub error{
# 	my ($self, $response) = @_;

# 	$self->api->jobFinished($self);
# 	#print "Error:".Dumper(@_); use Data::Dumper;
# 	&{$self->onError}($response);

# }

# sub progress{
# 	my ($self, $chunk, $req) = @_;

# 	$self->onProgress->($chunk, $req) if($self->onProgress);

# }	

sub process{
	my ($self) = @_;

	while(my $task = $self->queue->dequeue_nb()){

		# use Data::Dumper; print Dumper($task);

		if($task->{type} eq 'PROGRESS'){
			$self->progress($task->{chunk}, $task->{req});
		}	
		elsif($task->{type} eq 'END'){
			$self->api->jobFinished($self);
			$self->end($task->{res});
		}
		else{
			$self->api->jobFinished($self);
			$self->error($task->{res});
		}
	}
}

sub send{
	my ($self, $ua, $req) = @_;

	$self->api->newJob($self);

	$self->start();

	$self->queue(Thread::Queue->new);

	my $with_progress = ($self->onProgress) ? 1 : undef;

	$self->thread(

		threads->create(

			sub {

				my ($ua, $req, $queue, $with_progress) = @_;

				Eixo::Rest::RequestAsyncThread->new(


					ua=>$ua,
					req=>$req,
					queue=>$queue

				)->process($with_progress);
				

			}, $ua, $req, $self->queue, $with_progress

		)
	);

	$self->thread->detach();

	$self;
}
