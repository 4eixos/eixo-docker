package Eixo::Docker;

use 5.008;
use strict;
use warnings;

use parent qw(Eixo::Base::Clase);
use JSON;
use LWP::UserAgent;
use Net::HTTP;
use Eixo::Rest::Client;


# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

our $VERSION = '1.065';

our $IDENTITY_FUNC = sub {

    (wantarray)? @_ : $_[0];

};


sub get_dir_files{
    my $dir = $_[0];
    
    die("dir path specified doesn't exists") unless(-d $dir);
    
    opendir(my $fh_dir, $dir) || die("Error opening dir $dir:$!");
    
    my @list;
    
    while(my $file = readdir($fh_dir)){
    
        next if($file =~ /^\.+$/);
    
        push @list, "$dir/$file";
    
        push @list, get_dir_files("$dir/$file") if(-d "$dir/$file");
    
    }
    
    closedir($fh_dir);
    
    return @list;
}

1;
