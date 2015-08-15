use t::test_base;
use File::Temp;

SKIP: {

    skip "'DOCKER_TEST_HOST' env var is not set", 2 unless exists($ENV{DOCKER_TEST_HOST});
    use_ok "Eixo::Docker::Api";
    use_ok "Eixo::Docker::Image";

    eval{
        my $a = Eixo::Docker::Api->new($ENV{DOCKER_TEST_HOST});

	my @images;

	eval{
		@images = $a->images->search(term=>'sshd');
	};
	if($@){
		print Dumper($@);
	}
	
	ok(@images > 0, "We have received some results");	

	my $n_images = scalar(@images);

	ok((grep {

		ref($_) eq "HASH" &&

		exists($_->{description}) && 
	
		exists($_->{is_official}) &&

		exists($_->{is_automated}) &&

		exists($_->{name}) &&

		exists($_->{star_count})

	} @images) == $n_images, 'All images are in correct format');

	$a->images->searchAsync(

		term => 'sshd',

		sub {
			my @i = @_;

			ok(scalar(@i) == $n_images, 'async mode works');

		}

	);

	$a->waitForJobs;

    };
    if($@){
        print Dumper($@);
    }
}

done_testing();

