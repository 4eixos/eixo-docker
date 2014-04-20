package Eixo::Docker::Job;

use strict;
use warnings;

use Eixo::Base::Clase;

has (
    id  => 0,
    params => undef,
    results => undef,
    status => 'NEW',
    wait_for_results => undef,
);



sub process {

    my ($self, $msg) = @_;

    if($self->status eq "SEND"){

        if($msg){
            $self->status("ACK");
        }
        else{

            $self->status("KO_ACK");
            $self->results("Message not received");
            return undef;
        }


        ($self->wait_for_results)?
            undef:
            $self->status("END");
    }
    else{

        $self->status("END");

        $self->results($msg);
    }


}


sub finished {

    $_[0]->status =~ /^(END|KO_ACK)$/

}

1;
