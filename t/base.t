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

BEGIN { plan tests => 41 }

# just check that all modules can be compiled
ok(eval {require GPS::gpsd; 1}, 1, $@);
ok(eval {require GPS::gpsd::point; 1}, 1, $@);
ok(eval {require GPS::gpsd::satellite; 1}, 1, $@);

my $g = GPS::gpsd->new(do_not_init=>1);
ok(ref $g, "GPS::gpsd");
ok($g->host, "localhost");
ok($g->port, "2947");

my $p = GPS::gpsd::point->new();
ok(ref $p, "GPS::gpsd::point");

my $s = GPS::gpsd::satellite->new();
ok(ref $s, "GPS::gpsd::satellite");

my $s1 = GPS::gpsd::satellite->new(qw{23 37 312 34 0});
ok($s1->prn, 23);
ok($s1->elevation, 37);
ok($s1->azimuth, 312);
ok($s1->snr, 34);
ok($s1->used, 0);

my $p1 = GPS::gpsd::point->new({
           O=>[qw{tag 1142128600 o2 38.85 -77.1 o5 o6 o7 63.4 25.2
                  o10 o11 o12 o13}],
           S=>[1],
           D=>['2006-03-04T05:52:03.77Z'],
           M=>[1],
         });
my $p2 = GPS::gpsd::point->new({
           O=>[qw{. 1142128673 . 39.0990087676253 -77.012214398776 . . . . . . . . .}],
         });
ok($p1->fix, 1);
ok($p1->status, 1);
ok($p1->datetime, '2006-03-04T05:52:03.77Z');
ok($p1->tag, 'tag');
ok($p1->time, 1142128600);
ok($p1->errortime, 'o2');
ok($p1->latitude, 38.85);
ok($p1->lat, 38.85);
ok($p1->longitude, -77.1);
ok($p1->lon, -77.1);
ok($p1->altitude, 'o5');
ok($p1->alt, 'o5');
ok($p1->errorhorizontal, 'o6');
ok($p1->errorvertical, 'o7');
ok($p1->heading, 63.4);
ok($p1->speed, 25.2);
ok($p1->climb, 'o10');
ok($p1->errorheading, 'o11');
ok($p1->errorspeed, 'o12');
ok($p1->errorclimb, 'o13');
ok($p1->mode, 1);

ok($g->time($p1,$p2), 73);
ok($g->distance($p1,$p2), 11577.7083494725);
my $p3=$g->track($p1, 73);
ok($p3->lat, 39.0990087676253);
ok($p3->lon, -77.012214398776);
ok($p3->time, 1142128673);
ok($g->distance($p2,$p3), 0);
ok($g->time($p2,$p3), 0);
