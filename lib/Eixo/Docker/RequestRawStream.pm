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
use Eixo::Docker::Job;
use Eixo::Docker;

use Carp;

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

	f_process=>$Eixo::Docker::IDENTITY_FUNC,

	f_line=> $Eixo::Docker::IDENTITY_FUNC,

	f_stdin=>undef,

	f_stdout=>undef,

	f_stderr=>undef,

	f_end=>undef,

	queue_in=>undef,

	queue_out=>undef,

	jobs => [],

    line_termination => "\n",

    timeout => 60,
);


sub process{
	my ($self,$multiplexed) = @_;

	#
	# We create a queue to handle communication
	#
	$self->queue_in(Thread::Queue->new);
	$self->queue_out(Thread::Queue->new);

	threads->new(sub {
		my ($self, $multiplexed) = @_;

        $self->_process($multiplexed);

	}, $self,$multiplexed)->detach;

	#
	# We encapsulate a callback to send commands
	#
    if($self->args->{stdin}){
	    
        # return 2 callbacks, 
        # 1 to send messages to docker , 
        # 2 to receive response|ack
        (
            sub {

	        	$self->queue_in->enqueue([++$JOB_ID, $_[0]]);

	        	push @{$self->jobs}, Eixo::Docker::Job->new(
	        	
	        		id => $JOB_ID,
	        		params => $_[0],
	        		status => 'SEND',
                    wait_for_results => ($self->args->{stdout} || $self->args->{stderr})
	        	);

	        	$JOB_ID;
	        },

	        sub {
	        	$self->wait_for_job($_[0])
	        }
        )
    }
    else{
        
        # callback to take messages from container
        sub {
            my $return = undef;

            while(defined(my $res = $self->queue_out->dequeue())){
                # print "resposta".Dumper($res);use Data::Dumper;
                # in perl 5.18 there is a q->end
                last if($res eq "END");

                # call f_process callback (for stream mode)
                $self->f_process->($res->[1]);
                $return = $res->[1];
           }

           $return;
        }
    }
}


sub wait_for_job{
	my ($self, $job_id) = @_;

    # if no job_id was passed, wait for all
    $job_id = '' unless($job_id);

    # job could be finished before wait
    if(my ($job) = grep {$_->finished && $_->id eq $job_id} @{$self->jobs}){

        return $job->results;
    }  


    # wait to finish the job
    while(grep { !$_->finished } @{$self->jobs}){

        #if(defined(my $res = $self->queue_out->dequeue_nb)){
        if(defined(my $res = $self->queue_out->dequeue)){

            #print "Recibimos:".Dumper($res);use Data::Dumper;

            my ($id, $result) = @$res;

            my $j = $self->getJob($id);

            croak("Job not found : $id") unless($j);
            
            $j->process($result);

            # if we found the job searched return with results
            return $j->results if($j->id eq $job_id && $j->finished);
        }

        # print "En wait_for_job\n";
        #print Dumper($self->jobs)."\n";

        select(undef,undef,undef,0.25);
    }

    # if no job_id was passed returns all results
    unless(defined($job_id)){
    
        return map {$_->results} @{$self->jobs};
        # return map {$_->id => $_->results} @{$self->jobs};
    }
    else{
        die("task not found in job list");
    }
}


sub getJob {
	my ($self, $job_id) = @_;

	(grep {$_->id eq $job_id} @{$self->jobs})[0];

}


sub _process{
	my ($self,$multiplexed) = @_;

	my ($host) = $self->host =~ /http\:\/\/(.+)$/;

	my $uri = $self->__buildUri();

	my $socket = Net::HTTP->new(

        Host=>$host,
        Timeout => $self->timeout,

    ) || die( ref($self) . '::process: error ' . $!);

	$socket->write_request($self->method => $uri);
	
	# if($multiplexed){
	# 	$self->_multiplexedStream($socket);
	# }
	# else{
	# 	$self->_stream($socket);
	# }

	my($code, $mess, %h) = $socket->read_response_headers;

    # check response headers
    confess("Error in http request: $mess (code = $code)") unless($code == 200);

    if($self->args->{stream}){
	   
       $self->_block($socket);

    }
    else{

        $self->_process_request_body($socket);
    }

	threads->exit();
}


sub _process_request_body{
    my ($self, $socket) = @_;

    my $data = '';
    my $buf = '';


    while (1) {

        $buf = '';

        my $n = $socket->read_entity_body($buf, 1024);
        # my $n = $socket->sysread($buf, 1024);

        # print "leemos $n bytes do body da request\n";

        if(!defined($n)){

            if($! != EAGAIN || $! != EINTR){

                die("Read failed: $!");
            }
        }

        last unless($n > 0);

        $data .= $buf;

    }

    my $result = (length($data) > 8)? 
        $self->unpack_response_content($data):
        "";

    $self->queue_out->enqueue([0,$result]);
    $self->queue_out->enqueue("END");
}

sub unpack_response_content{

    my ($self, $data) = @_;

    my $line_termination = $self->line_termination;

    my $result = '';

    if($data =~ /$line_termination/){

        foreach my $line (split($line_termination,$data)){

            my($stream_type,$length,$rest) = unpack('BxxxNA*', $line);
            # print "tipo:$stream_type|longitud:$length|resto_cadena:$rest\n";
            $result .= $rest.$line_termination;
        }
    }
    else{
        my($stream_type,$length,$rest) = unpack('BxxxNA*', $data);
        # print "NON HAI FIN DE LINEA:tipo:$stream_type|longitud:$length|resto_cadena:$rest\n";
        $result .= $rest;

    }

    $result;
}


sub _block{
    my ($self, $socket) = @_;

    my $job_id = 0;

    my $select = IO::Select->new($socket);
    
    while(1){

        # send message for stdin
        if($self->args->{stdin}){
        
            # block till receive message from q_in
            my $msg = $self->queue_in->dequeue;
    
            $job_id = $msg->[0];

            #
            # job_id = -1 indicates detach
            #
            last if($job_id == -1);
        
            my $send_status = $self->_sendCmd($msg->[1], $socket);

            # enqueue ACK 
            $self->queue_out->enqueue([$job_id, $send_status]);
        }

        # get response from stdout|stderrr
        if($self->args->{stdout} || $self->args->{stderr}){
            
            # set a timeout to read
            my @ready = $select->can_read($self->timeout);

            # if no response from socket in time, enqueue a empty string response
            # and jump to next job
            unless(@ready){

                # close thread if not using stdin
                unless($self->args->{stdin}){
                    # print "Timeout superado, encolando END\n";
                    $self->queue_out->enqueue("END");
                    last;
                }
                else{
                    # print "Timeout superado, encolando ''\n";
                    $self->queue_out->enqueue([$job_id,""]);
                    next;
                }
            }


            my $data = $self->process_socket_stream($select);

            # if read socket return undef, and no stdin stream connected, close thread
            if(!defined($data) && !$self->args->{stdin}){
                $self->queue_out->enqueue("END");
                last;
            }
            

            $self->queue_out->enqueue([$job_id,$data]);

        }

    }

}



sub process_socket_stream{

    my ($self,$select) = @_;
    my $STREAM_HEADER_SIZE_BYTES = 8;

    sub recvall{
        my ($socket, $size) = @_;

        my $data = '';
        my $buf = '';

        while($size > 0){
        
            # $socket->sysread($buf, $size);
            $socket->read_entity_body($buf, $size);

            return undef if($buf eq '');

            # print "pillamos buffer con '$buf', queda $size\n";

            $data .= $buf;
            $size -= length($buf);
        
        }

        $data;
    
    }

    # socket stream may be chunked
    my $data = '';
    while(my @ready = $select->can_read(0.25)){
        # print "hay algo no socket\n";
        my $socket = $ready[0];

        # print "vamos a leer a cabeceira\n";
        my $header = recvall($socket, $STREAM_HEADER_SIZE_BYTES);
        # print "leendo a cabeceira: $header\n";
        return unless($header);
    
        my($stream_type, $length) = unpack('BxxxL>', $header);
    
        return  unless($length > 0);
    
        # print "Vamos a leer do socket $length bytes que venhen do stream $stream_type\n";
    
        $data .= recvall($socket, $length);
    
        return unless(defined($data));
    }

     # print "leemos $data\n";
    # print "leemos en total " . length($data)." bytes\n";

    $data;

}


#sub _block{
#	my ($self, $socket) = @_;
#
#    # $self->args->{stdin}
#    # $self->args->{stdout}
#
#	my $flags;
#
#	fcntl($socket, F_GETFL, $flags)  or die "get : $!\n";
#
#	$flags |= O_NONBLOCK;
#
#	fcntl($socket, F_SETFL, $flags) or die "set: $!\n";
#
#	my $select = IO::Select->new;
#
#	$select->add($socket);
#
#	my $job_id = undef;
#
#	while(1){
#
#
#        # TODO:
#        # funciona ben mentres haxa salida (ou eco =>  Tty = true)
#        # se non hai saida (pq esta redirixida p.ex) hai que buscar outra forma
#		my @ready = $select->can_read(0.25);
#        #####
#			
#		if(@ready > 0){
#
#			last unless($self->f_process->($job_id, $ready[0]));
#		}
#		
#		if(my $job = $self->queue_in->dequeue_nb){
#			
#			$job_id = $job->[0];
#
#			$self->_sendCmd($job->[1], $socket);
#		}
#	}
#}

# sub _stream{
# 	my ($self) = @_;

# 	my $data = '';
 
# 	$self->f_process(sub {

# 		my $job_id = $_[0];

# 		my $socket = $_[1];

# 		my $ok = undef;

# 		my $n = 0;

# 		my $buf = '';

# 		while(!$ok){

#             #print "JOB: $job_id, Tratando de ler do socket\n";
# 			$n = $socket->sysread($buf, 1024);
#             #print "JOB: $job_id, Lemos $n bytes do socket: '$buf'\n";

# 			if(!defined($n)){

# 				if($! != EAGAIN){

# 					die($!);

# 				}
# 			}


# 			if($n > 0){

# 				$data .= $buf;

#                 last if($n < 1024);

# 			}
# 			else{
# 				$ok = 1;
# 			}
# 		}

# 		if($data =~ /\n/){
# 			$self->__send('LINE', $_) foreach(split(/\n/, $data));

# 			$self->queue_out->enqueue([$job_id,$data]);

# 			$data = '';
# 		}

# 		length($buf);

# 	});
#}

sub _sendCmd{
	my ($self, $cmd, $socket) = @_;

	$socket->syswrite($cmd . $self->line_termination);
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
