#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: base.t,v 0.1 2006/02/21 eserte Exp $
# Author: Michael R. Davis
#

use strict;

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "1..0 # tests only works with installed Test module\n";
	exit;
    }
}

BEGIN { plan tests => 8 }

# just check that all modules can be compiled
ok(eval {require GPS::gpsd; 1}, 1, $@);
ok(eval {require GPS::gpsd::point; 1}, 1, $@);
ok(eval {require GPS::gpsd::satellite; 1}, 1, $@);

my $gps = GPS::gpsd->new(do_not_init=>1);
ok(ref $gps, "GPS::gpsd");
ok($gps->host, "localhost");
ok($gps->port, "2947");

my $p = GPS::gpsd::point->new();
ok(ref $p, "GPS::gpsd::point");

my $s = GPS::gpsd::satellite->new();
ok(ref $s, "GPS::gpsd::satellite");
