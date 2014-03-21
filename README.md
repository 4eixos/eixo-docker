Eixo::Docker module
===================

Perl suite of modules to interact with Docker (http://docker.io) 

Installation
------------

To install this module type the following:

     perl Build.PL  
    ./Build  
    ./Build test  
    ./Build install  

or traditional method:   

    perl Makefile.PL
    make
    make test
    make install
   
Dependencies
------------

Currently this module has the following dependencies:  

 - JSON >= 2.50,
 - LWP::UserAgent >= 5.0,
 - Net::HTTP   >= 6.06,
 - HTTP::Server::Simple::CGI (for testing purpose)

Usage
-----

- First we need docker api server running in a tcp socket
  
   For example, to run api in localhost:4243, add this line to **/etc/default/docker**

        DOCKER_OPTS="-H 127.0.0.1:4243 -d"
        
    And restart docker service

- Now to interact with it, instantiate a docker api client with the tcp socket url of the docker API:

```perl  

    use Eixo::Docker::Api;

    my $a = Eixo::Docker::Api->new('http://127.0.0.1:4243');
```

- From now on you can call all the Docker api methods throught api products (**containers** and **images**), passing the args indicated in [api documentation](http://docs.docker.io/en/latest/reference/api/docker\_remote\_api/):  

    Usage examples: 

```perl  

    #
    # CONTAINERS
    #

    ## get (by id)
    my $c = $a->containers->get(id => "340f03a2c2cfxx");

    ## getByName
    my $c = $a->containers->getByName("testing123");

    # create
    # to see all available params 
    # http://docs.docker.io/en/latest/api/docker_remote_api_v1.10/#create-a-container
    my $c = $a->container->create(
        Hostname => 'test',
	    Memory	 => 128,
	    Cmd => ["ls","-l"],
	    Image => "ubuntu",
	    Name => "testing123"
    );

    ## delete
    $c->delete();

    #
    # IMAGES
    #

    ## get
    my $image = $a->images->get(id => "busybox");

    ## create
    my $image = $a->images->create(
    
        fromImage=>'busybox',
    
        onSuccess=>sub {
            
            print "FINISHED\n";     
    
        },

        onProgress=>sub{
    
            print $_[0] . "\n";
        }
    );
    
    ## history 
    print Dumper($image->history);

    ## build
    my $image = $a->images->build(
        t => "my_image",
        Dockerfile => join("\n", <DATA>),
    );

    ## build_from_dir
    my $image = $a->images->build_from_dir(
        t => "my_image",
        DIR => "/tmp/directroy_with_a_Dockerfile"
    );

    ## delete
    $image->delete();
    

```

**Containers** supported methods:

- get
- getByName
- getAll
- create 
- delete
- status
- start
- stop
- restart
- kill
- copy
- attach
- top  


**Images** supported methods:  

- get
- getAll
- history
- create
- build
- build_from_dir
- insertFile
- delete


Caveats
-------
- No unix socket support, currently only supports tcp connections to Docker API.


To setup development environment:
--------------------------------

Ubuntu 12.04 64bits:

Install kernel 3.8 

    # install the backported kernel
    sudo apt-get update
    sudo apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring
    
    # reboot
    sudo reboot


Install docker:

    curl -s https://get.docker.io/ubuntu/ | sudo sh


Setup docker daemon listening in localhost:4243 tcp port:

- Add this line to **/etc/default/docker**

        DOCKER_OPTS="-H 127.0.0.1:4243 -d"


- restart docker service:

        $ sudo service docker restart

- export **DOCKER\_TEST\_HOST** var to run integration tests

        export DOCKER_TEST_HOST=http://127.0.0.1:4243

More info at http://docs.docker.io

    
COPYRIGHT AND LICENSE
---------------------

Copyright (C) 2014, Francisco Maseda

Copyright (C) 2014, Javier Gómez


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
