#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd;

use strict;
use vars qw($VERSION);
use IO::Socket;
use Math::Trig;
use GPS::gpsd::point;

$VERSION = sprintf("%d.%02d", q{Revision: 0.3} =~ /(\d+)\.(\d+)/);

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->initialize(@_);
  return $self;
}

sub initialize {
  my $self = shift();
  my %param = @_;
  $self->host($param{'host'} || 'localhost');
  $self->port($param{'port'} || '2947');
  $self->send($param{'send'} || 'SDOV');
  my $data=$self->getserverdata('LKIFCB');
  foreach (keys %$data) {
    $self->{$_}=$data->{$_};
  }
}

sub register {
  my $self = shift();
  my %param = @_;
  my $sub=$param{'sub'} || die('Error: sub=>\&{} required');
  my $filter=$param{'filter'} || sub{1};
  while (1) {
    my $point=$self->get();
    if ($point->fix) { #if gps fix
      if (&{$filter}($point)) {
        &{$sub}($point);
        sleep 1; 
      }
    }
  }
}

sub getserverdata {
  my $self=shift();
  my $send=shift();
  my $sock=$self->open();
  my $data='';
  if (defined($sock)) {
    $sock->send($send) or die("Error: $!");
    $sock->recv($data, 256); #Not sure if 256 is good here!
    chomp $data;
    return $self->parse($data);
  } else {
    print "$0: Could not connect to gspd host.\n";
    return undef();
  }
}


sub get {
  my $self=shift();
  my $sock=$self->open();
  my $data='';
  if (defined($sock)) {
    $sock->send($self->send()) or die("Error: $!");
    $sock->recv($data, 256); #Not sure if 256 is good here!
    chomp $data;
    #return $self->parse($data);
    my $point=GPS::gpsd::point->new($self->parse($data));
    return $point;
  } else {
    print "$0: Could not connect to gspd host.\n";
    return undef();
  }
}

sub open {
  my $self=shift();
  my $host=$self->host();
  my $port=$self->port();
  my $sock = IO::Socket::INET->new(PeerAddr => $host,
                                   PeerPort => $port);
  return $sock;
}

sub parse {
  my $self=shift();
  my $line=shift();
  my %data=();
  my @line=split(/[,\n\r]/, $line);  
  foreach (@line) {
    if (m/(.*)=(.*)/) {
      $data{$1}=[split(/ /, $2)];
    }
  }
  return \%data;
}

sub send {
  my $self = shift();
  if (@_) { $self->{'send'} = shift() } #sets value
  return $self->{'send'};
}

sub port {
  my $self = shift();
  if (@_) { $self->{'port'} = shift() } #sets value
  return $self->{'port'};
}

sub host {
  my $self = shift();
  if (@_) { $self->{'host'} = shift() } #sets value
  return $self->{'host'};
}

sub time {
  #seconds between p1 and p2
  my $self=shift();
  my $p1=shift();
  my $p2=shift();
  return abs($p2->time - $p1->time);
}

sub distance {
  #meters between p1 and p2
  my $self=shift();
  my $p1=shift();
  my $p2=shift();
  my $y1=$p1->lat;
  my $x1=$p1->lon;
  my $y2=$p2->lat;
  my $x2=$p2->lon;
  return sqrt(($x2-$x1)**2 + ($y2-$y1)**2) * 40075.16 / 360 * 1000;
}

sub track {
  #return calculated point of $p1 at time $p2 assuming constant velocity
  my $self=shift();
  my $p1=shift();
  my $p2=shift();
  my $x1=$p1->lon;
  my $y1=$p1->lat;
  my $heading=$p1->heading;        #degrees from the North
  my $speed=$p1->{'V'}->[0];          #knots; 1knot=1min/hr=1/3600 deg/sec
  my $time=$self->time($p1,$p2);
  my $x1v=$x1 + sin(deg2rad($heading)) * $speed/3600 * $time;
  my $y1v=$y1 + cos(deg2rad($heading)) * $speed/3600 * $time;
  my $p1v={%$p1};
  $p1v->{'P'}=[$y1v, $x1v];  #Is there a better OO way to make assignments?
  return $p1v;
}

sub baud {
  my $self = shift();
  return q2u $self->{'B'}->[0];
}

sub rate {
  my $self = shift();
  return q2u $self->{'C'}->[0];
}

sub device {
  my $self = shift();
  return q2u $self->{'F'}->[0];
}

sub identification {
  my $self = shift();
  return q2u $self->{'I'}->[0];
}

sub id {
  my $self = shift();
  return $self->identification;
}

sub protocol {
  my $self = shift();
  return q2u $self->{'L'}->[0];
}

sub server {
  my $self = shift();
  return q2u $self->{'L'}->[1];
}

sub commands {
  my $self = shift();
  return q2u $self->{'L'}->[2];
}

sub q2u {
  my $a=shift();
  return $a eq '?' ? undef() : $a;
}


1;
__END__

=head1 NAME

  GPS::gpsd is a module that provides a perl interface to the gpsd daemon. gpsd is an open source gps deamon from http://gpsd.berlios.de/.

=head1 SYNOPSIS

  use GPS::gpsd;
  $gps = new GPS::gpsd(  host    => 'localhost',
	  		 port      => 2947
                );
  my $fix=$gps->get();

  or

  use GPS::gpsd;
  $gps->register(sub=>\&gps_handler);
  sub gps_handler {
    my $data=shift();
    print "Lat:". $data->{'P'}->[0]. " Lon:". $data->{'P'}->[1]. "\n";
  }


=head1 DESCRIPTION

  GPS::gpsd provides a very simple interface to gpsd daemon in perl scripts.
 
  For example the method get() returns a hash reference like
                     {S=>[?|0|1|2],
                      P=>[lat,lon]}

  Unfortunately you'll still need to know the single character protocol of the gpsd daemon.

=over

=head1 GETTING STARTED

=head1 KNOWN LIMITATIONS

  The subroutine registration could use some more work.  I'd like to add a min time, max time, position tolerance and tracking tolerance capabilities.

=head1 BUGS

  No known bugs.

=head1 EXAMPLES

#!/usr/bin/perl
use strict;
use lib './';
use GPS::gpsd;

my $gps=GPS::gpsd->new(host=>'192.168.33.130',
                       port=>2947);
my $data=$gps->get();
my %fix=('?'=>"Error", 0=>"No Fix", 1=>"Fix", 2=>"DGPS-Corrected Fix");
print "gpsd.pm Version:", $gps->VERSION, "\n";
print "gpsd Version:", $data->{'L'}->[1], "\n";
print "Fix:", $data->{'S'}->[0], "=", $fix{$data->{'S'}->[0]}, "\n";
print "Lat:", $data->{'P'}->[0], " Lon:", $data->{'P'}->[1], "\n";
print "Host:", $gps->host, " Port:", $gps->port, "\n";

$gps->register(sub=>\&gps_handler);

sub gps_handler {
  my $data=shift();
  print join " ", "Fix", $data->{'S'}->[0], $data->{'P'}->[0], $data->{'P'}->[1], "\n";
}

=head1 AUTHOR

  Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

  gpsd http tracker http://twiki.davisnetworks.com/bin/view/Main/GpsApplications
  gpsd home http://gpsd.berlios.de/

=cut
