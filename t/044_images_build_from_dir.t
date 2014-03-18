use t::test_base;
use File::Temp;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    use_ok "Eixo::Docker::Api";
    use_ok "Eixo::Docker::Image";

    eval{
        my $TEST_IMAGE_NAME = 'testing_image123_' . int(rand(1000));

        my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});
        my $tempdir = File::Temp->newdir();

        open my $fh, '>', "$tempdir/file1";
        print $fh $_."\n" foreach (1..1000);
        close $fh;

        mkdir("$tempdir/dir1");
        open $fh, '>', "$tempdir/dir1/file2";
        print $fh $_."\n" foreach (1..1000);
        close $fh;
        
        mkdir("$tempdir/dir1/dir2");
        open $fh, '>', "$tempdir/dir1/dir2/file3";
        print $fh $_ x100 foreach (1..100000); # long file(49MB)
        close $fh;

        open $fh, '>', $tempdir->dirname."/Dockerfile";
        print $fh join("\n", <DATA>);
        close $fh;

        my $i = $a->images->build_from_dir(
            t => $TEST_IMAGE_NAME,
            DIR => $tempdir->dirname
        );

        my @hitos = map {$_->CreatedBy} $i->history;

        ok(
            (grep {/ADD file/} @hitos) &&
            (grep {/ADD dir/} @hitos) &&
            (grep {/ADD dir/} @hitos),
            
            "Build steps checked"
        );



        $i->delete() if($i);
    };
    if($@){
        print Dumper($@);
    }
}

done_testing();

__DATA__
FROM ubuntu

ADD file1 /tmp/
ADD dir1/ /tmp/dir1
ADD dir1/dir2/ /tmp/dir1/dir2

