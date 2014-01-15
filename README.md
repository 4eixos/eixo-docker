Eixo::Docker module
===================

Perl module to interact with Docker API (http://docs.docker.io/en/latest/api/docker_remote_api_v1.8/)


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

- Add this line to /etc/default/docker.conf

        DOCKER_OPTS="-H 127.0.0.1:4243 -d"


- restart docker service:

        $ sudo service docker restart
