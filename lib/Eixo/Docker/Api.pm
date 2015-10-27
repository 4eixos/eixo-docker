package Eixo::Docker::Api;

use strict;
use warnings;
use Eixo::Base::Clase qw(Eixo::Rest::Api);

use Eixo::Docker::EventRegister;

my $CERT_PATH = $ENV{DOCKER_CERT_PATH} || '';

has(
    host => $ENV{DOCKER_HOST},
    tls_verify => $ENV{DOCKER_TLS_VERIFY},
    ca_file => $CERT_PATH.'/ca.pem',
    cert_file => $CERT_PATH.'/cert.pem',
    key_file => $CERT_PATH.'/key.pem',
);

sub initialize {   
    my ($self, @args) = @_;

    if(@args % 2){

        # if pass an odd number of args in new
        # firt one must be the docker host
        $self->host(shift(@args));


    }
    
    # rest of initialization has to be manual
    my %args = @args;
    
    while(my ($key, $val) = each(%args)){
        $self->$key($val);
    }

    my ($proto, $host) = split ('://', $self->host);
    

    ($host = $proto and $proto = undef) unless($host);    
    
    if(!$proto || $proto eq 'tcp'){

        $proto = ($self->tls_verify)? 'https' : 'http';
    
    }


    $self->SUPER::initialize(
        
        "$proto://$host",

        ssl_opts => {
            ($proto eq 'https')?
            (
                SSL_use_cert => 1,
                verify_hostname => 1,
                SSL_ca_file => $self->ca_file,
                SSL_cert_file => $self->cert_file,
                SSL_key_file => $self->key_file

            ):()
        }
    )

}

sub containers {
	$_[0]->produce(

        ($_[0]->__legacy)?
        'Eixo::Docker::ContainerLegacy':
        'Eixo::Docker::Container'

    );
}

sub images {
	$_[0]->produce('Eixo::Docker::Image');
}

sub version{
	$_[0]->produce('Eixo::Docker::Version');
}

sub events{
	$_[0]->produce('Eixo::Docker::Events');
}

sub eventPool{
	my ($self) = @_;
	
	return $self->{ev} if($self->{ev});

	$self->{ev} = Eixo::Docker::EventRegister->new(

		$self,

		
	);
}

sub __legacy {
    $_[0]->version->get->ApiVersion <= 1.19
}

1;
