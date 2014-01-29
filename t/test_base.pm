use strict;
use warnings;

use Test::More;
use Data::Dumper;
use Carp;
use File::Basename;
use Cwd qw(abs_path);

BEGIN{
	my $ruta = abs_path(join('/', dirname(__FILE__), '..', 'lib'));

	push @INC, $ruta;	
}

my $LIMIT = 20;

sub change_state{
	my ($c, $new_state) = @_;

	die("Expected container as first argument") unless(ref($c) eq 'Eixo::Docker::Container');
	die("'up', 'down' are the only valid states") unless(grep {$new_state eq $_} qw(up down));

	return 1 if(&is_up($c) && $new_state eq 'up');
	return 1 if(&is_down($c) && $new_state eq 'down');

	my $change = ($new_state eq 'up') ? \&is_up : \&is_down;	

	if($new_state eq 'up'){
		$c->start();
	}
	else{
		$c->stop();
	}
	
	my $i = 0;
	while(!$change->($c) && $i < $LIMIT){
		sleep(1);
		$i++;
	}
	
	$change->($c);
	
}



sub is_up {
	my $c = shift;

	$c->status()->{Running};


}


sub is_down {
	!&is_up(@_);
}

1;
