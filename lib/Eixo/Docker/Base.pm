
package Eixo::Docker::Base;
use strict;

my $STASH = {};

sub new{
	return bless($_[1], $_[0]);
}

sub stashSet {
	$STASH->{$_[0]} = $_[1];
}

sub stashGet{
	$STASH->{$_[0]};
}

sub Log {
	if($STASH->{f_log}){
		&{$STASH->{f_log}}(@_);
	}
}
