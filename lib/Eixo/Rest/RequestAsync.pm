package Eixo::Rest::RequestAsync;

use strict;

use threads;
use Thread::Queue;

use JSON -convert_blessed_universally;

use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

use Eixo::Rest::RequestAsyncThread;

has (

	job_id=>undef,

	callback=>undef,

	api=>undef,

	onProgress => undef,
	onSuccess =>  undef,
	onFailure => undef,
	onStart => undef,
	
	thread=>undef,
	queue=>undef,

);

sub start{
	my ($self) = @_;

	if($self->onStart){
		$self->onStart->();
	}
}

sub end{

	$_[0]->api->jobFinished($_[0]);


	&{$_[0]->onSuccess}(
	
		$_[0]->callback->(JSON->new->decode($_[1])),

		$_[1]
	);
}

sub error{

	$_[0]->api->jobFinished($_[0]);

	die("EIQUI\n");
}

sub progress{
	my ($self, $chunk, $req) = @_;

	$self->onProgress->($chunk, $req) if($self->onProgress);

}	

sub process{
	my ($self) = @_;

	while(my $task = $self->queue->dequeue_nb()){

		if($task->{type} eq 'PROGRESS'){
			$self->progress($task->{chunk}, $task->{req});
		}	
		elsif($task->{type} eq 'END'){
			$self->end($task->{res});
		}
		else{
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
