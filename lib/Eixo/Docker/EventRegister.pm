package Eixo::Docker::EventRegister;

use strict;

use JSON;
use IO::Select;
use Eixo::Docker::EventPool;
use Eixo::Docker::Event;

sub new{

	return bless({

		api=>$_[1],

		frequency=>$_[2],

		pid_pool=>undef,

		r_pool=>undef,

		s_pool=>undef,

		events=>{},

		pool=>[],

	}, $_[0]);
}

sub DESTROY	{

	return unless($_[0]->{pid_pool});

	kill('TERM', $_[0]->{pid_pool});

	waitpid($_[0]->{pid_pool}, 0);
}

#
# It will block forever 
#
sub condvar{
	my ($self) = @_;

	my $s = IO::Select->new;

	$s->add($self->{r_pool});

	while($s->can_read){
		$self->run;
	}
}

sub run{
	my ($self) = @_;

	return unless($self->{pid_pool});

	$self->__getEvents;

	$self->__runEvents;
}

sub registerEvent{
	my ($self, %args) = @_;

	if(!$self->{pid_pool}){

		$self->__launchPool;
	}

	my $signature = join('-', $args{id}, $args{status});

	$self->{events}->{$signature} = Eixo::Docker::Event->new(

		$args{id},

		$args{status},

		$args{code} || sub {}
	);
}

sub __getEvents{
	my ($self) = @_;

	my @lines;

	my $r = $self->{r_pool};

	while(my $l = $r->getline){
		push @lines, $l;
	}

	foreach(grep { $_ =~ /\w/ } @lines){
		push @{$self->{pool}}, JSON->new->decode($_);
	}
}

sub __runEvents{
	my ($self) = @_;

	foreach my $e (@{$self->{pool}}){

		if(my $event = $self->__isRegistered($e)){

			$event->run($e);	

		}
	}

	$self->{pool} = [];
}

sub __isRegistered{
	my ($self, $e) = @_;

	my $signature = join('-', $e->{id}, $e->{status});

	$self->{events}->{$signature} || undef;
}

sub __launchPool{
	my ($self) = @_;

	my $pool = Eixo::Docker::EventPool->new(

		0,

		$self->{api},

		$self->{frequency} || 1
	
	)->create;

	$self->{pid_pool} = $pool->{pid};	

	$self->{r_pool} = $pool->{reader};
	
	$self->{r_pool}->blocking(0);

	#$self->{s_pool} = IO::Select->new;

	#$self->{s_pool}->add($self->{r_pool});
}



1;
