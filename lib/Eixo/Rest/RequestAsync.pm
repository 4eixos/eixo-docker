package Eixo::Rest::RequestAsync;

use Coro;
use strict;
use Eixo::Base::Clase;

use Attribute::Handlers;
use Eixo::Rest::Client;
use Carp;

has (

	onProgress => undef,
	onSuccess =>  undef,
	onFailure => undef,
	onStart => undef,
	

);

sub start{
	my ($self) = @_;

	if($self->onStart){
		$self->onStart->();
	}
}

sub end{
	&{$_[0]->onSuccess};
}

sub error{
	die("EIQUI\n");
}

sub progress{
	my ($self, $chunk, $req) = @_;
	
	$self->onProgress->($chunk, $req) if($self->onProgress);

	cede;
}	

sub send{
	my ($self, $ua, $req) = @_;

	async {
		$self->start();
	
		my $res = $ua->request($req, sub {
	
			$self->progress(@_);
	
		});
	
		if($res->is_success){
			$self->end($res);
		}
		else{
			$self->error($res);
		}
	
		$self;
	};

	cede;
}
