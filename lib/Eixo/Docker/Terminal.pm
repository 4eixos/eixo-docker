package Eixo::Docker::Terminal;

use strict;
use warnings;

use Eixo::Base::Clase;

#
# Docker pseudo-terminal
#

has(
    container=>undef, 
    
    f_in=>undef,
    
    f_out=>undef,
    
    timeout => 5,
	
);

sub initialize{
    # print $_[0]->container;
    #
    # Attach a client thread to the system
    #
    my ($f_in, $f_out) = $_[0]->container->attach(
        
        stream=>1,
        
        stdin=>1,
        
        stdout=>1,
        
        stderr=>1,
        
        timeout => $_[0]->timeout,
    );
    
    $_[0]->f_in($f_in);
    $_[0]->f_out($f_out);
}

sub send{
    my ($self, $cmd, @args) = @_;
    
    my $job = $self->f_in->(join(' ', $cmd, @args));
    
    my $ret = $self->f_out->($job);
    
    chomp $ret if($ret);
    
    $ret;
}

#
# Silent method
#
sub sendS{
    my ($self, $cmd, @args) = @_;
    
    $self->send($cmd, @args, ';', '/bin/echo', '"END"');
}

1;
