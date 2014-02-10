package Eixo::Rest::RequestSync;

use strict;
use Eixo::Rest::Request;
use parent qw(Eixo::Rest::Request);

sub progress{
    my ($self, $chunk, $req) = @_;

    $self->onProgress->($chunk, $req) if($self->onProgress);

}   



sub send{
    my ($self, $ua, $req) = @_;

    $self->start();

    my $res = ($self->onProgress)? 

        $ua->request($req, sub {

            $self->progress(@_);

        }) : $ua->request($req);

    if($res->is_success){
        return $self->end($res);
    }
    else{
        return $self->error($res);
    }

    # $self;
}

1;