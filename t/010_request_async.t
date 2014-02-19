use t::test_base;

BEGIN{
	use_ok("Eixo::Rest::RequestAsync");
}

#
# We create a fake UserAgent and a fake Api
# 
my $TIMES = 5;

my $api = FakeApi->new;
my $ua = FakeUserAgent->new($TIMES, 'OK');

my @chunks;
my $end;

my $request_async = Eixo::Rest::RequestAsync->new(

	api=>$api,

	onProgress=>sub {
		push @chunks, $_[0];
	},

	onSuccess=>sub{
		$end = $_[0];
	},

	callback=>sub{
		@_;
	},

	__format=>'RAW'

);

$request_async->send($ua, undef);

#
# Waiting for the jobs to finish
#
$api->waitForJobs();

is(scalar(@chunks), $TIMES, 'Progress of request seems ok');

is(scalar(grep { 'CHUNK_' .$_ ~~ @chunks } (1..$TIMES)), $TIMES, 'Type of progress seems all right');

is($end, 'OK', 'The request ended well');

done_testing();

package FakeApi;

sub new{
	bless({jobs=>[]});
}

sub newJob{
	push @{$_[0]->{jobs}}, $_[1];
}

sub jobFinished{
	$_[0]->{jobs} = [grep { $_ != $_[1]} @{$_[0]->{jobs}}];
}

sub waitForJobs{

	while(scalar(@{$_[0]->{jobs}})){
	
		foreach(@{$_[0]->{jobs}}){

			$_->process;

			select(undef, undef, undef, 0.05);
		}
	}
}


package FakeUserAgent;

sub new{
	return bless({t=>$_[1], success=>$_[2], content=>$_[3] || $_[2]});
}

sub is_success{
	return $_[0]->{success};
}

sub content{
	return $_[0]->{content};
}

sub request{
	my ($self, $req, $code) = @_;

	for(1..$self->{t}){

		$code->('CHUNK_' . $_, $self);		

        select(undef,undef,undef,0.25);
	}

	$self;
}



