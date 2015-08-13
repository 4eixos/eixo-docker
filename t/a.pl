#use Eixo::Docker::EventPool;

#my $datos = Eixo::Docker::EventPool->new(0,0,1)->create;

use Eixo::Docker::EventRegister;

my $et = Eixo::Docker::EventRegister->new;

$et->registerEvent;

for(1..4){

	sleep(1);

	$et->run;
}

