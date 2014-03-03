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
use IO::Handle;
use Eixo::Docker::Job;

my $JOB_ID = 0;

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

	queue_in=>undef,

	queue_out=>undef,

	jobs => [],
);


sub process{
	my ($self, $multiplexed) = @_;

	#
	# We create a queue to handle communication
	#
	$self->queue_in(Thread::Queue->new);
	$self->queue_out(Thread::Queue->new);

	threads->new(sub {
		my ($self, $multiplexed) = @_;

		$self->_process($multiplexed);

	}, $self, $multiplexed)->detach;

	#
	# We encapsulate a callback to send commands
	#
	(sub {

		$self->queue_in->enqueue([++$JOB_ID, $_[0]]);

		push @{$self->jobs}, Eixo::Docker::Job->new(
		
			id => $JOB_ID,
			params => $_[0],
			status => 'SEND',
		);

		$JOB_ID;
	},

	sub {
		$self->wait_for_job($_[0])
	})
}


sub wait_for_job{
	my ($self, $job_id) = @_;

    while(grep {$_->{status} ne 'END'} @{$self->jobs}){

        if(my $res = $self->queue_out->dequeue_nb){

            my $j = $self->getJob($res->[0]);
            $j->{results} = $res->[1];
            $j->{status} = 'END';
            #print "Algo cheogou!!".Dumper($self->{jobs});use Data::Dumper;

            # if we found the job searched return with results
            return $j->results if($j->id eq $job_id);
        }   

        select(undef,undef,undef,0.25);
    }   

}

sub getJob {
	my ($self, $job_id) = @_;

	(grep {$_->id eq $job_id} @{$self->jobs})[0];

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

	threads->exit();
}

sub _block{
	my ($self, $socket) = @_;

	my $flags = '';

	fcntl($socket, F_GETFL, $flags)  or die "get : $!\n";

	$flags |= O_NONBLOCK;

	fcntl($socket, F_SETFL, $flags) or die "set: $!\n";

	my $select = IO::Select->new;

	$select->add($socket);

	my $job_id = undef;

	while(1){

		my @ready = $select->can_read(0.25);
			
		if(@ready > 0){

			last unless($self->f_process->($job_id, $ready[0]));
		}
		
		while(my $job = $self->queue_in->dequeue_nb){
			
			$job_id = $job->[0];

			$self->_sendCmd($job->[1], $socket);
		}
	}
}

sub _stream{
	my ($self) = @_;

	my $data;

	$self->f_process(sub {

		my $job_id = $_[0];

		my $socket = $_[1];

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

			$self->queue_out->enqueue([$job_id,$data]);

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

	$destiny = $destiny || $self->f_line;

	if($destiny){
		$destiny->($data);
	}
}



1;
