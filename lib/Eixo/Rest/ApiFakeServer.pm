package Eixo::Rest::ApiFakeServer;

use strict;
use Eixo::Base::Clase;

has(

	listeners=>{},

	cgi=>undef,

);

sub start{
	my ($self, $port) = @_;

	return Eixo::Rest::ApiFakeServerProcess::start_server(

		$port,

		$self
	);
}

sub process{
	my ($self, $cgi) = @_;

	$self->cgi($cgi);

	$self->__send(

		$self->listeners->{$cgi->path_info} ||
		

		$self->__defaultListener

	);

}

sub __defaultListener{
	{}
}

sub __send{
	my ($self, $response) = @_;

	($response->{header}) ? $response->{header}->($self) : $self->__header;

	($response->{body}) ? $response->{body}->($self) : $self->__body;

}

sub __header{

	print "HTTP/1.0 200 OK\r\n";
	print $_[0]->cgi->header(-type  =>  'text/plain');
}

sub __body{

}

package Eixo::Rest::ApiFakeServerProcess;

use strict;
use parent qw(HTTP::Server::Simple::CGI);

sub start_server{
	my ($port, $api) = @_;

	my $server = __PACKAGE__->new;

	$server->{api} = $api;

	$server->port($port);
	
	$server->background();

}

sub handle_request{
	my ($self, $cgi) = @_;

	$self->{api}->process($cgi);

}

1;
