package Eixo::Rest::RequestAsyncThread;

use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

has (

	queue=>undef,
	req=>undef,
	ua=>undef,

	buffer=>'',

);


sub process{
	my ($self, $with_progress) = @_;

	my $res = ($with_progress) ?  

		$self->ua->request($self->req, sub {

			$self->progress(@_);

		}) : $self->ua->request($self->req);

	if($res->is_success){

		$self->queue->enqueue({

			type=>'END',

			res=>$res
		})
	}
	else{
		$self->queue->enqueue({

			type=>'ERROR',

			res=>$res

		});
	}

	threads->exit();
}


sub progress{
	my ($self, $chunk, $req) = @_;

	$self->buffer($self->buffer . $chunk);

	$self->queue->enqueue({

		type=>'PROGRESS',

		chunk=>$chunk,

		req=>$req
	});
}

1;
