#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: base.t,v 0.1 2006/02/21 eserte Exp $
# Author: Michael R. Davis
#

use strict;
use lib q{lib};

sub near {
  my $x=shift();
  my $y=shift();
  my $p=shift()||5;
  if ($x-$y < 10**-$p) {
    return 1;
  } else {
    return 0;
  }
}

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "1..0 # tests only works with installed Test module\n";
	exit;
    }
}

BEGIN { plan tests => 43 }

# just check that all modules can be compiled
ok(eval {require GPS::gpsd; 1}, 1, $@);
ok(eval {require GPS::gpsd::Point; 1}, 1, $@);
ok(eval {require GPS::gpsd::Satellite; 1}, 1, $@);
ok(eval {require GPS::gpsd::Report::http; 1}, 1, $@);

my $g = GPS::gpsd->new(do_not_init=>1);
ok(ref $g, "GPS::gpsd");
ok($g->host, "localhost");
ok($g->port, "2947");

my $p = GPS::gpsd::Point->new();
ok(ref $p, "GPS::gpsd::Point");

my $s = GPS::gpsd::Satellite->new();
ok(ref $s, "GPS::gpsd::Satellite");

my $s1 = GPS::gpsd::Satellite->new(qw{23 37 312 34 0});
ok($s1->prn, 23);
ok($s1->elevation, 37);
ok($s1->azimuth, 312);
ok($s1->snr, 34);
ok($s1->used, 0);

my $p1 = GPS::gpsd::Point->new({
           O=>[qw{tag 1142128600 o2 38.865343 -77.110069 o5 o6 o7
                  53.649377382 21.37913373 o10 o11 o12 o13}],
           S=>[1],
           D=>['2006-03-04T05:52:03.77Z'],
           M=>[1],
         });
my $p2 = GPS::gpsd::Point->new({
           O=>[qw{. 1142128605 . 38.866119 -77.109338 . . . . . . . . .}],
         });
ok($p1->fix, 1);
ok($p1->status, 1);
ok($p1->datetime, '2006-03-04T05:52:03.77Z');
ok($p1->tag, 'tag');
ok($p1->time, 1142128600);
ok($p1->errortime, 'o2');
ok($p1->latitude, 38.865343);
ok($p1->lat, 38.865343);
ok($p1->longitude, -77.110069);
ok($p1->lon, -77.110069);
ok($p1->altitude, 'o5');
ok($p1->alt, 'o5');
ok($p1->errorhorizontal, 'o6');
ok($p1->errorvertical, 'o7');
ok(near $p1->heading, 53.649377382);
ok(near $p1->speed, 21.37913373);
ok($p1->climb, 'o10');
ok($p1->errorheading, 'o11');
ok($p1->errorspeed, 'o12');
ok($p1->errorclimb, 'o13');
ok($p1->mode, 1);

ok($g->time($p1,$p2), 5);
ok($g->distance($p1,$p2), 106.895668646645); #plainer calc - should be 107.0 spherical
my $p3=$g->track($p1, 5);
ok(near $p3->lat, 38.866119);
ok(near $p3->lon, -77.109338);
ok($p3->time, 1142128605);
ok($g->distance($p1,$p1), 0);
ok(near $g->distance($p2,$p3), 0, 3);
ok($g->time($p2,$p3), 0);
