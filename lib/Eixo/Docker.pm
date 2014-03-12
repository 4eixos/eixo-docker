package Eixo::Docker;

use 5.008;
use strict;
use warnings;

use parent qw(Eixo::Base::Clase);
use JSON;
use LWP::UserAgent;
use Eixo::Rest::Client;


# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

our $VERSION = '0.01';

our $IDENTITY_FUNC = sub {

    (wantarray)? @_ : $_[0];

};



1;
