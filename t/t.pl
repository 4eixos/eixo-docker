use test_base;

use Eixo::Docker::Api;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

eval {
    my $c = $a->containers->getByName('testing_1233_');
    
    &change_state($c, 'up');
    
    my ($fcmd, $fout) = $c->attach(
    
        stdout=>1,
        stderr =>1,
        stdin=>1,
        stream=>1,
    );

    my @ids;

    while( my $cmd = <STDIN> ){
        print "enviando $cmd",
        chomp($cmd);
        last if($cmd eq 'exit');

        push @ids,$fcmd->($cmd);
    }

    foreach(@ids){
        print $fout->($_);
    }


    


};
if($@){
    print Dumper($@);
}
