use t::test_base;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    use_ok "Eixo::Docker::Api";
    use_ok "Eixo::Docker::Image";

    eval{
        my $TEST_IMAGE_NAME = 'testing_image123_' . int(rand(1000));

        my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

        my $i = $a->images->build(
            t => $TEST_IMAGE_NAME,
            Dockerfile => join("\n", <DATA>),
        );

        ok($i && ref($i) eq "Eixo::Docker::Image", "Image build from Dockerfile");

        my @hitos = map {$_->CreatedBy} $i->history;

        #print Dumper($i->history);

        ok(
            (grep {/MAINTAINER test/} @hitos), 
            "MAINTAINER command applied correctly"
        );
        ok(
            (grep {/echo \"testing\"/} @hitos), 
            "RUN command applied correctly"
        );

        $i->delete() if($i);

    };
    if($@){
        print Dumper($@);
    }
}
    

done_testing();


__DATA__

FROM base

MAINTAINER test

RUN echo "testing" > /tmp/test
