Eixo::Docker module
===================

Perl module to interact with Docker API (http://docs.docker.io/en/latest/reference/api/docker_remote_api/)

Installation
------------

To install this module type the following:

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
    my $a = Eixo::Docker::Api->new('http://127.0.0.1:4243');
```

- From now on you can call all the Docker api methods throught api products (**containers** and **images**), passing the args indicated in api documentation:
    For example: 

```perl
    my $container = $a->containers->get(id => "340f03a2c2cfxx");
    $container->delete();
    
    my $image = $a->images->get(id => "busybox");
    print Dumper($image->history);
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
- inspect
- history
- getAll
- create
- build
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

- export **DOCKER_TEST_HOST** var to run integration tests

        export DOCKER_TEST_HOST=http://127.0.0.1:4243

More info at http://docs.docker.io

    
COPYRIGHT AND LICENSE
---------------------

Copyright (C) 2013-2014, Fmaseda

Copyright (C) 2013-2014, Javier Gómez


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
