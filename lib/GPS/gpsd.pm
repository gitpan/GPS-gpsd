#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd;

use strict;
use vars qw($VERSION);
use IO::Socket;
use GPS::gpsd::Point;
use GPS::gpsd::Satellite;

$VERSION = sprintf("%d.%02d", q{Revision: 0.13} =~ /(\d+)\.(\d+)/);

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
  unless ($param{'do_not_init'}) { #for testing
    my $data=$self->retrieve('LKIFCB');
    foreach (keys %$data) {
      $self->{$_}=[@{$data->{$_}}]; #there has got to be a better way to do this...
    }
  }
}

sub subscribe {
  my $self = shift();
  my %param = @_;
  my $last=undef();
  my $handler=$param{'handler'} || \&default_handler;
  my $config=$param{'config'} || {};
  while (1) {
    my $point=$self->get();
    if (defined($point) and $point->fix) { #if gps fix
      my $return=&{$handler}($last, $point, $config);
      if (defined($return)) {
        $last=$return;
      }
    }
    sleep 1; 
  }
}

sub default_handler {
  my $p1=shift(); #last true return or undef if first
  my $p2=shift(); #current fix
  my $config=shift(); #configuration data
  print $p2->lat, " ", $p2->lon,"\n";
  return $p2;
}

sub getsatellitelist {
  my $self=shift();
  my $string='Y';
  my $data=$self->retrieve($string);
  my @data = @{$data->{'Y'}};
  shift(@data);             #Drop sentence tag
  my @list = ();
  foreach (@data) {
    #print "$_\n";
    push @list, GPS::gpsd::Satellite->new(split " ", $_);
  }
  return @list;
}

sub get {
  my $self=shift();
  my $data=$self->retrieve('SDO');
  return GPS::gpsd::Point->new($data);
}

sub retrieve {
  my $self=shift();
  my $string=shift();
  my $sock=$self->open();
  my $data='';
  if (defined($sock)) {
    $sock->send($string) or die("Error: $!");
    $sock->recv($data, 256); #Not sure if 256 is good here!
    chomp $data;
    return $self->parse($data);
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
      if ($1 eq 'Y') {
        $data{$1}=[split(/:/, $2)]; #Y is : delimited
      } else {
        $data{$1}=[map {$_ eq '?' ? undef() : $_} split(/\s+/, $2)];
      }
    }
  }
  return \%data;
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
  #returns meters between p1 and p2
  my $self=shift();
  my $p1=shift();
  my $p2=shift();
  my $earth_polar_circumference_meters_per_degree=6356752.314245 * 2*&PI/360;
  my $earth_equatorial_circumference_meters_per_degree=6378137 * 2*&PI/360;
  my $delta_lat_degrees=$p2->lat - $p1->lat;
  my $delta_lon_degrees=$p2->lon - $p1->lon;
  my $delta_lat_meters=$delta_lat_degrees * $earth_polar_circumference_meters_per_degree;
  my $delta_lon_meters=$delta_lon_degrees * $earth_equatorial_circumference_meters_per_degree * cos(($p1->lat + $delta_lat_degrees / 2) * &PI / 180);
  #print $delta_lat_meters, ":",  $delta_lon_meters, "\n";
  return sqrt($delta_lat_meters**2 + $delta_lon_meters**2);
}

sub track {
 #return calculated point of $p1 in time assuming constant velocity
  my $self=shift();
  my $p1=shift();
  my $time=shift();
  my $distance_meters=$p1->speed * $time;   #meters
  my $earth_polar_circumference_meters_per_degree=6356752.314245 * 2*&PI/360;
  my $earth_equatorial_circumference_meters_per_degree=6378137 * 2*&PI/360 * cos($p1->lat*&PI/180);
  my $distance_lat_meters=$distance_meters * sin($p1->heading*&PI/180);
  my $distance_lon_meters=$distance_meters * cos($p1->heading*&PI/180);
  #print  $distance_lat_meters, ":", $distance_lon_meters, "\n";
  my $distance_lat_degrees=$distance_lat_meters
                               / $earth_polar_circumference_meters_per_degree;
  my $distance_lon_degrees=$distance_lon_meters
                           / $earth_equatorial_circumference_meters_per_degree;
  #print  $distance_lat_degrees, ":", $distance_lon_degrees, "\n";
  my $p2=GPS::gpsd::Point->new($p1);
  $p2->lat($p1->lat + $distance_lat_degrees);
  $p2->lon($p1->lon + $distance_lon_degrees);
  $p2->time($p1->time + $time);
  #$p2->heading($dird); #what is the new heading?
  return $p2;
}

sub PI {4 * atan2 1, 1;}

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

sub daemon {
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

=pod

=head1 NAME

GPS::gpsd - Provides a perl interface to the gpsd daemon. 

=head1 SYNOPSIS

 use GPS::gpsd;
 $gps=new GPS::gpsd();
 my $point=$gps->get();
 print $point->lat, " ", $point->lon, "\n";

or

 use GPS::gpsd;
 $gps=new GPS::gpsd();
 $gps->subscribe();

=head1 DESCRIPTION

GPS::gpsd provides a perl interface to gpsd daemon.  gpsd is an open source gps deamon from http://gpsd.berlios.de/.
 
For example the method get() returns a hash reference like

 {S=>[?|0|1|2],
  P=>[lat,lon]}

Fortunately, there are various methods that hide this hash from the user.

=head1 METHODS

=over

=item new

Returns a new gps object.

=item subscribe(handler=>\&sub, config=>{})

Subscribes subroutine to call when a valid fix is obtained.  When the GPS receiver has a good fix this subroutine will be called every second.  The return (in v0.5 must be a ref) from this sub will be sent back as the first argument to the subroutine on the next call.

=item get

Returns a current point object regardless if there is a fix or not.  Application should test if $point->fix is true.

=item getsatellitelist

Returns a list of satellite objects.  (maps to gpsd Y command)

=item port

Get or set the current gpsd TCP port.

=item host

Get or set the current gpsd host.

=item time(p1, p2)

Returns the time difference between two points in seconds.

=item distance(p1, p2)

Returns the distance difference between two points in meters. (plainer calculation)

=item track(p1, time)

Returns a point object at the predicted location of p1 in time seconds. (plainer calculation based on speed and heading)

=item baud

Returns the baud rate of the connect GPS receiver. (maps to gpsd B command first data element)

=item rate

Returns the sampling rate of the GPS receiver. (maps to gpsd C command first data element)

=item device

Returns the GPS device name. (maps to gpsd F command first data element)

=item identification (aka id)

Returns a text string identifying the GPS. (maps to gpsd I command first data element)

=item protocol

Returns the gpsd protocol revision number. (maps to gpsd L command first data element)

=item daemon

Returns the gpsd daemon version. (maps to gpsd L command second data element)

=item commands

Returns a string of accepted request letters. (maps to gpsd L command third data element)

=back

=head1 GETTING STARTED

=head1 KNOWN LIMITATIONS

=head1 BUGS

No known bugs.

=head1 EXAMPLES

 #!/usr/bin/perl
 use strict;
 use lib './';
 use GPS::gpsd;

 my $gps=GPS::gpsd->new();
 my $data=$gps->get();
 my %fix=('?'=>"Error", 0=>"No Fix", 1=>"Fix", 2=>"DGPS-Corrected Fix");
 print "gpsd.pm Version:", $gps->VERSION, "\n";
 print "gpsd Version:", $data->{'L'}->[1], "\n";
 print "Fix:", $data->{'S'}->[0], "=", $fix{$data->{'S'}->[0]}, "\n";
 print "Lat:", $data->{'P'}->[0], " Lon:", $data->{'P'}->[1], "\n";
 print "Host:", $gps->host, " Port:", $gps->port, "\n";

 $gps->subscribe(handler=>\&gps_handler);

 sub gps_handler {
   my $point=shift();
   print join " ", "Fix", $point->{'S'}->[0], $point->{'P'}->[0], $point->{'P'}->[1], "\n";
   return $point
 }

=head1 AUTHOR

Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

gpsd http tracker http://twiki.davisnetworks.com/bin/view/Main/GpsApplications

gpsd home http://gpsd.berlios.de/

=cut
