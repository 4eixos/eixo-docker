package Eixo::Docker::Image;

use strict;
use Eixo::Rest::Product;
use parent qw(Eixo::Rest::Product);

use Eixo::Docker;
use Eixo::Docker::Config;
use Eixo::Docker::ImageResume;
use Archive::Tar;
use Cwd;

my @BUILD_QUERY_PARAMS = qw(t tag q quiet nocache rm);

has(
    id => undef,			
    parent => undef,		
    created => undef,	
    container => undef, 
    container_config => {},
    Size => 0, 		
    config => {},
    comment => undef,
    architecture => undef,
    docker_version => undef,
    os => undef,
    history=>[],
);



sub initialize{
	my $self = $_[0];

	# set default Docker::Rest::Client error callback 
	# to call when API response error is received
	$self->api->client->error_callback(
	    sub { $self->error(@_) }    
	);
	
	$self;
}

sub get{
	my ($self, %args) = @_;

	$args{id} = $self->id if($self->id);

	$self->api->getImages(

		needed=>[qw(id)],

		args=>\%args,

		__callback=>sub {

			$self->populate($_[0]);
			
			if(my %h = %{$self->container_config}){
				$self->container_config(Eixo::Docker::Config->new(%h));
			}

			if(my %h = %{$self->config}){
				$self->config(Eixo::Docker::Config->new(%h));
			}

			$self;

		}
	);


}


sub history{
	my ($self, %args) = @_;

	$args{id} = $self->id unless($args{id});

	$args{action} = 'history';

	$args{__implicit_format} = 1;

	$self->api->getImages(

		needed=>[qw(id)],

		args=>\%args,

		__callback=>sub {


			map { 

				Eixo::Docker::ImageResume->new(%{$_})

			} @{$_[0]};

		}

	);
}

sub getAll{
	my ($self, %args) = @_;

	my $list = [];

	$args{all} = 1;


	$self->api->getImages(

		args=>\%args, 

		get_data => [qw(all)],

		__callback=>sub {

 			foreach(@{$_[0]}){
				push @$list, Eixo::Docker::ImageResume->new(%$_);
			}

			$list;
		}

	);


}

sub create{
	my ($self, %args) = @_;


	# actually, only fromImage it's supported

	my $image = $args{fromImage};

	$args{action} = 'create';

	$args{__format} = 'RAW';

	$self->api->postImages(

		needed=>[qw(fromImage)],

		args=>\%args,

		get_params=>[qw(fromImage repo tag registry)],

		__callback=>sub {

			$self->get(id=>$image);

			return $self;
		}
	);

}

# TODO 
# sub import{}

sub build{
    my ($self, %args) = @_;

    # args must be string-files to use in build (except build query params)
    # Dockerfile is a must

    die("Dockerfile arg doesn't exists") unless(defined($args{Dockerfile}));
    
    my $tar = Archive::Tar->new;

    while(my ($name, $data) = each (%args)){
        
        next if (grep {$_ eq $name} @BUILD_QUERY_PARAMS);

        $tar->add_data($name, $data);

        delete($args{$name});
    }

    $self->_build($tar, %args);
}


sub build_from_dir{
    
    my ($self, %args) = @_;

    die("DIR arg is not present") unless(defined($args{DIR}));

    my $dir = delete($args{DIR});


    my $olddir = getcwd();

    chdir($dir);

    my @list = Eixo::Docker::get_dir_files('.');

    my $tar = Archive::Tar->new;

    $tar->add_files(@list);

    chdir($olddir);

    $self->_build($tar, %args);


}


sub _build {

    my ($self, $tar, %args) = @_;

    my $image_name =  $args{t} || $args{tag} || die("Lacks 'tag' param");

    my $get_data = { 
        t => $image_name,
        rm => "1", # remove intermediate containers
    };

    $get_data->{q} = $args{q} || $args{quiet} if(defined($args{q}||$args{quiet}));
    $get_data->{nocache} = $args{nocache} if(defined($args{nocache}));

    my $params = {
        
        GET_DATA => $get_data,
        POST_DATA => $tar->write(),
        HEADER_DATA => {"Content-Type", "application/tar"},
        __format => "RAW"
    };

    my $PROGRESS_ERROR = undef;

    $self->api->postBuild(
        
        args => $params,

        onProgress => sub {
            my $resp = JSON->new->utf8->decode($_[0]);
            
            if($resp->{"error"}){
                $PROGRESS_ERROR = "Error building image: ".$resp->{errorDetail}->{message};
            }
        },

		__callback=>sub {
            $self->error("build", $PROGRESS_ERROR) if($PROGRESS_ERROR);

			$self->get(id=>$image_name);

			return $self;
		}
    );


}



sub insertFile{
	my ($self, %args) = @_;
	
	$args{action} = 'insert';

	$args{__format} = 'RAW';
	
	my $ID_NEW_IMAGE;
	
	my $f_get_id = sub {

		($ID_NEW_IMAGE) = $_[0] =~ /\"status\"\:\"([^"]+)\"\}/;
	
	};

	$self->api->postImages(

		needed=>[qw(url path id)],

		args=>\%args,

		get_params=>[qw(url path)],

		onProgress => sub {

			&$f_get_id($_[0]);


		},

		__callback=>sub {

			#
			# Take the last id and use it to get the new image
			#
			&$f_get_id($_[0]) if($_[0]);

			$self->api->images->get(id=>$ID_NEW_IMAGE);
		
		},
	

	);
}


sub delete{
	my ($self, %args) = @_;

	$args{id} = $self->id unless($args{id});

	$self->api->deleteImages(

		needed=>[qw(id)],
		
		args=>\%args

	);
}

1;
