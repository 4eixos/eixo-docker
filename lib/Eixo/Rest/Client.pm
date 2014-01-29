package Eixo::Rest::Client;
use strict;

use Eixo::Base::Clase;
use URI;
use LWP::UserAgent;
use JSON -convert_blessed_universally;
use Carp;
use Data::Dumper;

my $REQ_PARSER = qr/\:\:([a-z]+)([A-Z]\w+?)$/;

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
		confess(ref($self) . ': UNKNOW METHOD: ' . $method);
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
    #print("Sending request to $uri with query ".$uri->query."\n");

	my $res = $self->$method($uri, %args);
    #print("Response: $res\n");

	return $res;
}

sub DESTROY {}


sub get : __log {

	my ($self, $uri, %args) = @_;

	$uri->query_form($args{GET_DATA});

	my $req = HTTP::Request->new(GET => $uri);

	$self->__send($req);
}

sub post : __log {
	my ($self,$uri,%args) = @_;

    # Is possible to add query string args to post requests
    $uri->query_form($args{GET_DATA});

	my $req = HTTP::Request->new(POST => $uri);
    $req->header('content-type' => 'application/json');

    my $content = JSON->new->allow_blessed(1)
                            ->convert_blessed(1)
                            ->encode($args{POST_DATA} || {});

    $req->content($content);
	
    
	$self->__send($req);
}

sub delete : __log {

	my ($self, $uri, %args) = @_;

	$uri->query_form($args{GET_DATA});

	my $req = HTTP::Request->new(DELETE => $uri);

	$self->__send($req);
}

sub patch :__log {
	my ($self, $uri, %args) = @_;

	$uri->query_form($args{GET_DATA});

	my $req = HTTP::Request->new(PATCH => $uri);

	$self->__send($req);

}

sub put :__log {
	my ($self, $uri, %args) = @_;

	$uri->query_form($args{GET_DATA});

	my $req = HTTP::Request->new(PUT=> $uri);

	$self->__send($req);

}


sub build_uri {
	my ($self, $entity, $id,$action) = @_;

	my $uri = $self->{endpoint}.'/'.$entity;
	
	$uri .= '/'.$id if(defined($id));
	$uri .= '/'.$action if(defined($action));

    ($self->current_method =~ /^get/)?
        URI->new($uri.'/'.$self->{format}):
        URI->new($uri);
}


sub generate_query_str {
	my ($self, %args) = @_;

	join '&', map {"$_=$args{$_}"} keys(%args);
}


sub __send{

	my ($self, $req) = @_;
	my $uri = $req->uri;
     	#print "Sending request $uri with method ".$req->method. " and content ".$req->content."\n";

	my $res = $self->ua->request($req);
     	#print "Response: ".Dumper($res)."\n";

	if($res->is_success){
		if($res->content){
			if ($self->format eq 'json' ){
				return JSON->new->decode($res->content);
			}
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
