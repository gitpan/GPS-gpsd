#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd::point;

use strict;
use vars qw($VERSION);

$VERSION = sprintf("%d.%02d", q{Revision: 0.6} =~ /(\d+)\.(\d+)/);

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
  my $data = shift();
  foreach (keys %$data) {
    $self->{$_}=$data->{$_};
  }
}

sub fix {
  my $self = shift();
  return ($self->status > 0);
}

sub status {
  my $self = shift();
  return q2u $self->{'S'}->[0];
}

sub datetime {
  my $self = shift();
  return q2u $self->{'D'}->[0];
}

sub tag {
  my $self = shift();
  return q2u $self->{'O'}->[0];
}

sub time {
  my $self = shift();
  return q2u $self->{'O'}->[1];
}

sub errortime {
  my $self = shift();
  return q2u $self->{'O'}->[2];
}

sub latitude {
  my $self = shift();
  return q2u $self->{'O'}->[3];
}

sub lat {
  my $self = shift();
  return $self->latitude;
}

sub longitude {
  my $self = shift();
  return q2u $self->{'O'}->[4];
}

sub lon {
  my $self = shift();
  return $self->longitude;
}

sub altitude {
  my $self = shift();
  return q2u $self->{'O'}->[5];
}

sub alt {
  my $self = shift();
  return $self->altitude;
}

sub errorhorizontal {
  my $self = shift();
  return q2u $self->{'O'}->[6];
}

sub errorvertical {
  my $self = shift();
  return q2u $self->{'O'}->[7];
}

sub heading {
  my $self = shift();
  return q2u $self->{'O'}->[8];
}

sub speed {
  my $self = shift();
  return q2u $self->{'O'}->[9];
}

sub climb {
  my $self = shift();
  return q2u $self->{'O'}->[10];
}

sub errorheading {
  my $self = shift();
  return q2u $self->{'O'}->[11];
}

sub errorspeed {
  my $self = shift();
  return q2u $self->{'O'}->[12];
}

sub errorclimb {
  my $self = shift();
  return q2u $self->{'O'}->[13];
}

sub mode {
  my $self = shift();
  return q2u $self->{'M'}->[0];
}

sub q2u {
  my $a=shift();
  return $a eq '?' ? undef() : $a;
}

1;
__END__

=pod

=head1 NAME

GPS::gpsd::point - Provides an object interface for a gps point.

=head1 SYNOPSIS

 use GPS::gpsd;
 $gps = new GPS::gpsd(host => 'localhost',
                      port => 2947
                );
 my $point=$gps->get(); #$point is a GPS::gpsd::point object
 print $point->latitude, " ", $point->longitude, "\n";

=head1 DESCRIPTION

=head1 METHODS

=over

=item fix

Returns true if status is fixed (logic based on the gpsd S command first data element)

=item status

Returns status. (maps to gpsd S command first data element)

=item datetime

Returns datetime. (maps to gpsd D command first data element)

=item tag

Returns a tag identifying the last sentence received.  (maps to gpsd O command first data element)

=item time

Returns Seconds since the Unix epoch, UTC. May have a fractional part of up to .01sec precision. (maps to gpsd O command second data element)

=item errortime

Returns estimated timestamp error (%f, seconds, 95% confidence). (maps to gpsd O command third data element)

=item latitude aka lat

Returns Latitude as in the P report (%f, degrees). (maps to gpsd O command fourth data element)

=item longitude aka lon

Returns Longitude as in the P report (%f, degrees). (maps to gpsd O command fifth data element)

=item altitude aka alt

Returns the current altitude, meters above mean sea level. (maps to gpsd O command sixth data element)

=item errorhorizontal

Returns Horizontal error estimate as in the E report (%f, meters). (maps to gpsd O command seventh data element)

=item errorvertical

Returns Vertical error estimate as in the E report (%f, meters). (maps to gpsd O command eighth data element)

=item heading

Returns Track as in the T report (%f, degrees). (maps to gpsd O command ninth data element)

=item speed

Returns Speed (%f, meters/sec). Note: older versions of the O command reported this field in knots. (maps to gpsd O command tenth data element)

=item climb

Returns Vertical velocity as in the U report (%f, meters/sec). (maps to gpsd O command 11th data element)

=item errorheading

Returns Error estimate for course (%f, degrees, 95% confidence). (maps to gpsd O command 12th data element)

=item errorspeed

Returns Error estimate for speed (%f, meters/sec, 95% confidence). Note: older versions of the O command reported this field in knots. (maps to gpsd O command 13th data element)

=item errorclimb

Returns Estimated error for climb/sink (%f, meters/sec, 95% confidence). (maps to gpsd O command 14th data element)

=item mode

Returns The NMEA mode. 0=no mode value yet seen, 1=no fix, 2=2D (no altitude), 3=3D (with altitude). (maps to gpsd M command first data element)

=back

=head1 GETTING STARTED

=head1 KNOWN LIMITATIONS

=head1 BUGS

No known bugs.

=head1 EXAMPLES

=head1 AUTHOR

Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

GPS::gpsd

GPS::gpsd::satellite

=cut
