package t_thread;

use threads;
use Thread::Queue;
my $JOB_ID = 0;

sub new{

    bless({
            q_in => undef,
            q_out => undef,
            jobs => [],
        });

}


sub process{

    my $self = $_[0];

    $self->{q_in} = Thread::Queue->new();
    $self->{q_out} = Thread::Queue->new();

    threads->new(sub{
            my ($self) = @_;
            $self->_process($q_out);
        },$self)->detach();


    sub {
        print "enviando $_[0]\n";
        $self->{q_in}->enqueue([++$JOB_ID,$_[0]]);
        push @{$self->{jobs}}, Job->new(id => $JOB_ID, params => $_[0], status => "START");
        $JOB_ID;
    }

}

sub jobs {
    my $self = $_[0];
    my $id = $_[1] || undef;

    ($id)? (grep {$_->{id} eq $id } @{$self->{jobs}})[0] : @{$self->{jobs}};

}

sub wait_for_jobs{
    my $self = $_[0];
    # my $id = $_[1];

    while(grep {$_->{status} ne 'END'} $self->jobs){

        print "Esperando por algo na q_out\n";

        if(my $res = $self->{q_out}->dequeue_nb){
            my $j = $self->jobs($res->[0]);
            $j->{resultados} = $res->[1];
            $j->{status} = 'END';
            print "Algo cheogou!!".Dumper($self->{jobs});use Data::Dumper;
        }

        select(undef,undef,undef,0.25);
    }

}

sub _process {
    my ($self) = @_;
    
    while (my $item = $self->{q_in}->dequeue()) {
        print "desencolamos item ".$item->[1]." con id ".$item->[0]."\n";
        sleep(1);
        print "Encolamos resultados\n";
        $self->{q_out}->enqueue([$item->[0], "ejecutado correctamente job ".$item->[1]]);
    }

}


package Job;

sub new {
    my ($class, %args) = @_;

    bless({%args})
}


package main;
use Data::Dumper;

my $t = t_thread->new;

my ($f_in) = $t->process();

while(my $linea = <STDIN>){
    chomp($linea);
    last if($linea eq 'exit');
    my $id = $f_in->($linea);
    #print Dumper($f_out->());
    #print Dumper(\($t->jobs));
}

$t->wait_for_jobs();
