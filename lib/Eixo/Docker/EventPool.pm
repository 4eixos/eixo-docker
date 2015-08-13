package Eixo::Docker::EventPool;

use strict;
use IO::Handle;

use JSON;

sub new{
	
	return bless({

		filter=>$_[1] || undef,

		api=>$_[2],

		frequency=>$_[3]

	}, $_[0]);

}

sub create{
	my ($self) = @_;

	my ($reader, $writer);

	pipe($reader, $writer);

	$writer->autoflush(1);

	if(my $pid = fork){
		
		close($writer);	

		return {
			
			pid=>$pid,

			reader=>$reader
		}
	}
	else{

		$self->{writer} = $writer;

		$SIG{TERM} = sub {
			exit 0;
		};

		eval{
			$self->loop;
		};
		if($@){
			print "CRASHED : $@\n";
			exit 1;
		}
	}
}

sub loop{
	my ($self) = @_;

	$self->{last} = time - 10;

	while(1){

		my $events = $self->__getEvents();

		$self->__sendEvents($events);
	}
}

sub __getEvents{
	my ($self) = @_;

	my $n_time = time + $self->{frequency};

	my $events = $_[0]->{api}->events->get(

		until=>$n_time,

		since=>$self->{last}
	);

	$self->{last} = $n_time;

	return $events;

}

sub __sendEvents{
	my ($self, $events) = @_;

	my $w = $self->{writer};

	my $json = JSON->new;

	foreach my $e (@{$events->{Events}}){

		print $w $json->encode($e) . "\n";

	}

	$events->{Events} = [];
}

1;
