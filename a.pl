use IO::Socket::INET;

use Net::HTTP;

my $s = Net::HTTP->new(Host => "localhost:4243") || die $@;

$s->write_request(GET=>'/containers/json');

my($code, $mess, %h) = $s->read_response_headers;

 while (1) {
    my $buf;
    my $n = $s->read_entity_body($buf, 1024);
    die "read failed: $!" unless defined $n;
    last unless $n;
    print $buf;
 }
