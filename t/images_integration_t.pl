use strict;
use warnings;

use Coro;
use lib './lib';
use Test::More;
use Data::Dumper;
use JSON;

use Eixo::Docker::Api;

my @calls;

my $a = Eixo::Docker::Api->new("http://localhost:4243");

#
# Set a logger sub
#
$a->flog(sub {

    my ($api_ref, $data, $args) = @_;

    push @calls, $data->[1];

});

my $i;
#$a->images->createAsync(fromImage=>'busybox');#->async(


my @list;

#$a->images->createAsync(
#
#	fromImage=>'busybox',
#
#	sub {
#		print "Terminado\n"
#		push @list, \@_;
#	}
#
#);
#
#my $img;

my @images = qw(fedora centos busybox);

my @instaladas;
my $todo_listo = undef;

foreach my $img (@images){

	$a->images->createAsync(
	
		fromImage=>$img,
		
		onProgress=>sub {

			print "$_[0]\n";	

		},
	
		onSuccess=>sub {
			
			push @instaladas, $img;
			print "Terminada instalacion $img\n\n";

			$todo_listo = 1 if(scalar(@instaladas) == scalar(@images));
	
		},
	
		onError=>sub{
	
		}
	
	);
}

while(!$todo_listo){
	#select(undef, undef, undef, 0.25);
	cede;
}

#$a->images->getAll();
#$a->images->get($id);
#$a->images->create();
#$a->images->delete();
done_testing();
