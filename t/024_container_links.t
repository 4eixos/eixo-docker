use t::test_base;

use Eixo::Docker::Api;

SKIP: {
    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});

    my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
    my ($c1, $c2);
    my $name1 = 'test_'.int(rand(1000));
    my $name2 = 'test_'.int(rand(1000));
    #
    eval{

        $a->images->create(fromImage=>'ubuntu',tag=>'14.04');

        $c1 = $a->containers->create(
            Hostname => 'test1',
            Cmd => ["perl", "-e", 'while(1){sleep(1)}'],
            Image => "ubuntu:14.04",
            Name => $name1,
        );

        $c2 = $a->containers->create(
            Hostname => 'test2',
            Cmd => ["perl", "-e", 'while(1){sleep(1)}'],
            Image => "ubuntu:14.04",
            Name => $name2,
            HostConfig => {
                Links => [
                
                    "$name1:test1"
                ] 
            }
        );

        $c1->start();
        $c2->start();

    };
    ok(!$@, "New containers created and started");

    ok(
        $c2->HostConfig->{Links}->[0] eq "/$name1:/$name2/test1",

        "Containers linked correctly",
    
    );

    eval{
        $c2->kill;
        $c1->kill;
        $c2->delete(delete_volumes => 1);
        $c1->delete(delete_volumes => 1);
    };
    ok(!$@, "Container deleted");
}

done_testing();
