package Eixo::Docker::Container;

use strict;
use warnings;

use Eixo::Base::Clase qw(Eixo::Rest::Product);

use Eixo::Docker::Config;
use Eixo::Docker::ContainerResume;
use Eixo::Docker::ContainerException;
use Eixo::Docker::HostConfig;
use Eixo::Docker::RequestRawStream;

my $DEFAULT_TIMEOUT = 30;

has(

    Id => undef, # new ID attribute from api#v1.12
	Created => '',
	Path => '',
	Args => [],
	State => {},
	Image => '',
	NetworkSettings => {},
    HostnamePath => '',
	ResolvConfPath => '',
	HostsPath => '',
	LogPath => '',
	Name => '',
    RestartCount => undef,
	Driver => '',
   	ExecDriver => '',
	ProcessLabel => '',
    MountLabel => '',
    AppArmorProfile =>  "",
    ExecIDs => undef,
    
    HostConfig => {},
    GraphDriver => {},
    Mounts => [],
	Config => {},
    
);

# Alias to fix name attribute changes in api#v1.12
sub ID { &Id(@_)}

sub initialize {
    my $self = $_[0];

    $self->SUPER::initialize(@_[1..$#_]);

    # set default Docker::Rest::Client error callback 
    # to call when API response error is received
    $self->api->client->error_callback(
        sub { $self->error(@_) }    
    );

    $self;
}

sub get{
	my ($self, %args) = @_;

	$args{id} = $self->Id || $args{id};

	$self->api->getContainers(

		needed=>[qw(id)],

		args=>\%args,
		
		__callback => sub {
    
			$self->populate($_[0]);


			# load config obj replacing config hash
			if(my %h = %{$self->Config}){ 
				$self->Config(Eixo::Docker::Config->new(%h))
			}

			if(my %h = %{$self->HostConfig}){
				$self->HostConfig(Eixo::Docker::HostConfig->new(%h))
			}

			$self;
		},
	);

}


sub getByName {
    my ($self, $name) = @_;

    return undef unless($name);

    $name = '/'.$name unless($name =~ /^\//);
    
    #get all containers
    my $list = $self->getAll();

    foreach my $c (@$list){
        return $self->get(id => $c->Id) if (grep {$name eq $_} @{$c->Names});
    }

}


sub getAll {

    my ($self,%args) = @_;

    my $list  = [];

    my $args = {
        all => 1,
        limit => $args{limit} || 1000,
    };

    $self->api->getContainers(

        args => $args,

        get_params => [qw(all limit)],

        __callback => sub {

            foreach my $r (@{$_[0]}){

                push @$list, Eixo::Docker::ContainerResume->new(%$r)
            }

            $list;
        }
    );

}


sub create {

	my ($self , %attrs) = @_;

	my $args = \%attrs;

	# convert args to correct params
	$args->{name} = $attrs{Name} if(exists($attrs{Name}));

	# validate attrs and initialize default values not setted
	my $config = Eixo::Docker::Config->new(%attrs);
    my $hostconfig = Eixo::Docker::HostConfig->new(%{$attrs{HostConfig}});
    delete($config->{api});
    delete($hostconfig->{api});

    my $create_data = {

        %$config, 
        HostConfig => {%$hostconfig},
        
    };

	$args->{action} = 'create';
	$args->{POST_DATA}  = $create_data;


	my $res = $self->api->postContainers(

	    args => $args,

	    get_params => [qw(name)],

        __callback => sub {
            my $result = $_[0];

            #return container fully loaded
            $self->get(id => $result->{Id});

            $self;

        }
    );

}


sub delete{
	my ($self, %args) = @_;

    $args{id} = $self->Id || $args{id};

    my $delete_volumes = (exists($args{delete_volumes}))? 
                            $args{delete_volumes}:
                            (exists($args{v}))? 
                                $args{v} :0;
    


    $args{GET_DATA} = {
            v => $delete_volumes
    };

	$self->api->deleteContainers(
		needed=>[qw(id)],
        args => \%args,
    );

}


sub status{
    my ($self, %args) = @_;

    $self->get(%args)->State;
}


sub start {
    my ($self, %args) = @_;

    # From API v1.24, start command does not accepts request body content anymore
    # https://docs.docker.com/engine/api/version-history/#v124-api-changes
    if( $self->api->version->get()->ApiVersion < '1.24' ) {
        my $config = Eixo::Docker::HostConfig->new->populate(\%args);
        $args{POST_DATA}  = $config;
    }

    $self->__exec("start", %args);

}

sub stop {
    my ($self, %args) = @_;

    $args{GET_DATA}->{t} =  (exists($args{timeout}))? 
                                $args{timeout}:
                                (exists($args{t}))? 
                                    $args{t} : $DEFAULT_TIMEOUT;
    $self->__exec("stop", %args);
    
}


sub restart {
    my ($self, %args) = @_;

    $args{GET_DATA}->{t} =  (exists($args{timeout}))? 
                                $args{timeout}:
                                (exists($args{t}))? 
                                    $args{t} : $DEFAULT_TIMEOUT;
    $self->__exec("restart", %args);

}

sub kill {
    my ($self, %args) = @_;

    $self->__exec("kill", %args);

}

sub copy{
	my ($self, %args) = @_;

	$args{id} = $self->Id unless($args{id});
	$args{action} = 'copy';

	$args{__format} = 'RAW';

	$self->api->postContainers(

		needed=>[qw(Resource)],

		args=>\%args,
	
		post_params=>[qw(Resource)],

		onProgress=>sub {
		},

		__callback=>sub {

			#use Data::Dumper; print Dumper(\@_);

			return $_[0] || $_[1]->buffer;

		}
	);
}

sub attach{
	my ($self, %args) = @_;

	$args{id} = $self->Id unless($args{id});

	$args{action} = 'attach';
	
	$args{$_} = $args{$_} || 0 foreach(qw(logs stream stdin stdout stderr));


    Eixo::Docker::RequestRawStream->new(

    	entity=>'containers',

    	id=>$args{id},

    	action=>'attach',

    	method=>'POST',

    	host=>$self->api->client->endpoint,

    	args=>\%args,

    	url_args=>[qw(logs stream stdin stdout stderr)],

    	f_line=>$args{f_line} || $Eixo::Docker::IDENTITY_FUNC,

        f_process => $args{f_process} || $Eixo::Docker::IDENTITY_FUNC,

        timeout => $args{timeout} || 60,

        tty_mode => $self->get(id => $args{id})->Config->Tty,

    )->process();

}

sub top{
	my ($self, %args) = @_;

	$args{id} = $self->Id unless($args{id});

	$args{__implicit_format} = 1;
	
	$args{action} = 'top';

	$self->api->getContainers(

		args=>\%args,

		get_params=>[qw(ps_args)],

		__callback=>sub{

			use Data::Dumper; print Dumper(\@_);

		}
		

	);

}

sub rename{
	my ($self, %args) = @_;

	$args{id} = $self->Id unless($args{id});

	$args{__implicit_format} = 1;

	$args{action} = 'rename';

	$self->api->postContainers(

		args=>\%args,

		get_params=>[qw(name)],

		needed=>[qw(name)],

		__callback=>sub{
            
            my $result = $_[0];

            #return container fully loaded
            $self->get(id => $result->{Id});

            $self;
		}

	);
}



sub __exec {
    my ($self, $action, %args) = @_;

    $args{id} = $self->Id;

    $args{action} = $action;

    $self->api->postContainers(

        needed => [qw(id)],

        args => \%args,

    );
}

sub __error {
	my ($self, $method, $reason,@args) = @_;

	Eixo::Docker::ContainerException->new(

		method => $method, 

		reason => $reason, 

		args => \@args

	)->raise();

}


1;
