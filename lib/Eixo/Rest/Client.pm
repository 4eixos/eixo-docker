package Eixo::Rest::Client;
use strict;

use Eixo::Base::Clase;
use URI;
use LWP::UserAgent;
use JSON;

my $REQ_PARSER = qr/([a-z]+)([A-Z]\w+?)$/;

has(

	ua=>undef,
	endpoint=>undef,
	format=>'json',
	flog=>undef,
	error_callback => undef,
	current_method => undef,
);

sub initialize{
	my ($self, $endpoint) = @_;

	$self->endpoint($endpoint);

	die("API ENDPOINT NEEDED") unless($self->endpoint);

	$self->ua("EixoAgent/0.1");

	$self;
}

sub ua {
	my ($self, $ua_str) = @_;

	if($ua_str){
		my $ua = LWP::UserAgent->new;
		$ua->agent($ua_str);
		$self->{ua} = $ua;
	}

	return $self->{ua};
}



sub AUTOLOAD{
	my ($self, %args) = @_;

	my ($method, $entity) = our $AUTOLOAD =~ $REQ_PARSER;
	
	# store current method for tracing
	$self->current_method($method.$entity);

	$entity = lc($entity);

	unless(grep { $method eq $_ } qw(put get post delete patch)){
		die(ref($self) . ': UNKNOW METHOD: ' . $method);
	}



	my ($id, $action);

	if(exists($args{id})){
		$id = $args{id};
		delete($args{id});
	}

	if(exists($args{action})){
		$action = $args{action};
		delete($args{action});
	}

	my $uri = $self->build_uri($entity, $id, $action);

	print("Sending request to $uri with query ".$self->generate_query_str(%args)."\n");
	my $res = $self->$method($uri, %args);
	print("Response: $res\n");

	return $res;
}

sub DESTROY {}

sub patch{
}

sub put{
	
}

sub get : __log {

	my ($self, $uri, %args) = @_;

	$uri->query_form(%args);

	my $req = HTTP::Request->new(GET => $uri);

	$self->__send($req);
}

sub post : __log {
	my ($self,$uri,%args) = @_;
	my $req = HTTP::Request->new(POST => $uri);
	$req->content($self->generate_query_str(%args));

	$self->__send($req);
}

sub delete{

}

sub build_uri {
	my ($self, $entity, $id,$action) = @_;

	my $uri = $self->{endpoint}.'/'.$entity;
	
	$uri .= '/'.$id if(defined($id));
	$uri .= '/'.$action if(defined($action));

	return URI->new($uri.'/'.$self->{format});
}


sub generate_query_str {
	my ($self, %args) = @_;

	join '&', map {"$_=$args{$_}"} keys(%args);
}


sub __send{

	my ($self, $req) = @_;

	my $res = $self->ua->request($req);

	if($res->is_success){
		if ($self->format eq 'json'){
			return JSON->new->decode($res->content);
		}
	}
	else{
		$self->remote_error(
				$res->code,
				$res->content
			);
	}

}

sub remote_error {
	my ($self,$status, @extra_args) = @_;

	if(defined($self->error_callback)){
		&{$self->error_callback}(
			$self->current_method,
			'ERROR_CODE',
			$status,
			@extra_args
			
		);
	}
	else{
		die "Remote Api error: (".$status."). Details: ".join(',', @extra_args)."\n";
	}
}


1;
