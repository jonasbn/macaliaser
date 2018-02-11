#!/usr/bin/env perl

use strict;
use warnings;
use Env qw($HOME);
use Data::Dumper;

my @blacklist = ();

if (-e "$HOME/.config/macaliaser/blacklist") {
    open (BLACKLIST, '<', "$HOME/.config/macaliaser/blacklist");
    while (<BLACKLIST>) {
        push @blacklist, $_;
    }
    close BLACKLIST;
}

print STDERR Dumper \@blacklist;
