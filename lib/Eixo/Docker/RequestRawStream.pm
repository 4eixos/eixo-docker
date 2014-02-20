package Eixo::Docker::RequestRawStream;

use strict;
use Eixo::Base::Clase;

use Net::HTTP;
use Data::Dumper;

use POSIX qw(:errno_h);
use Fcntl;
use IO::Select;

use threads;
use Thread::Queue;

has(

	entity=>undef,

	id=>undef,

	action=>undef,

	host=>undef,

	method=>undef,

	url_args=>[],

	query_args=>[],

	args=>{},

	f_process=>undef,

	f_line=>undef,

	f_stdin=>undef,

	f_stdout=>undef,

	f_stderr=>undef,

	f_end=>undef,

	queue=>undef
);


sub process{
	my ($self, $multiplexed) = @_;

	#
	# We create a queue to handle communication
	#
	my $queue = Thread::Queue->new;

	threads->new(sub {
		my ($self, $multiplexed, $queue) = @_;

		$self->queue($queue);
		
		$self->_process($multiplexed);

	}, $self, $multiplexed, $queue)->detach;

	#
	# We encapsulate a callback to send commands
	#
	sub {
		$queue->enqueue($_[0]);
	}
}

sub _process{
	my ($self, $multiplexed) = @_;

	my ($host) = $self->host =~ /http\:\/\/(.+)$/;

	my $uri = $self->__buildUri();

	my $socket = Net::HTTP->new(Host=>$host) || 

		die( ref($self) . '::process: error ' . $!);

	$socket->write_request($self->method => $uri);
	
	if($multiplexed){
		$self->_multiplexedStream($socket);
	}
	else{
		$self->_stream($socket);
	}

	$socket->read_response_headers;

	$self->_block($socket);
}

sub _block{
	my ($self, $socket) = @_;

	my $flags = '';

	fcntl($socket, F_GETFL, $flags)  or die "get : $!\n";

	$flags |= O_NONBLOCK;

	fcntl($socket, F_SETFL, $flags) or die "set: $!\n";

	my $select = IO::Select->new;

	$select->add($socket);

	while(1){

		my @ready = $select->can_read(0.25);
			
		if(@ready > 0){

			last unless($self->f_process->($ready[0]));
		}
		
		if(my $cmd = $self->queue->dequeue_nb){
			$self->_sendCmd($cmd, $socket);
		}
	}
}

sub _stream{
	my ($self) = @_;

	my $data;

	$self->f_process(sub {

		my $socket = $_[0];

		my $ok = undef;

		my $n = 0;

		my $buf;

		while(!$ok){

			$n = $socket->sysread($buf, 1024);

			if(!defined($n)){

				if($! != EAGAIN){

					die($!);

				}
			}


			if($n > 0){

				$data .= $buf;

			}
			else{
				$ok = 1;
			}
		}

		if($data =~ /\n/){

			$self->__send('LINE', $_) foreach(split(/\n/, $data));

			$data = '';
		}

		length($buf);

	});
}

sub _sendCmd{
	my ($self, $cmd, $socket) = @_;

	$socket->syswrite($cmd . "\n");
}

sub __buildUri{
	my ($self) = @_;

	'/' . join('/', 

		grep {

			defined($_)

		} ( $self->entity, $self->id, $self->action) 
	) .

	'?'

	 . join('&', map {

		$_ . '=' . $self->args->{$_}
	
	} @{$self->url_args});
}

sub __send{
	my ($self, $type, $data, $destiny) = @_;

	print "$data\n";

	$destiny = $destiny || $self->f_line;

	if($destiny){
		$destiny->($data);
	}
}



1;
