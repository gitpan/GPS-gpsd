#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd::satellite;

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
  $self->{'prn'} = shift();
  $self->{'elevation'} = shift();
  $self->{'azimuth'} = shift();
  $self->{'snr'} = shift();
  $self->{'used'} = shift();
}

sub prn {
  my $self = shift();
  return $self->{'prn'};
}

sub elevation {
  my $self = shift();
  return $self->{'elevation'};
}

sub elev {
  my $self = shift();
  return $self->elevation;
}

sub azimuth {
  my $self = shift();
  return $self->{'azimuth'};
}

sub azim {
  my $self = shift();
  return $self->azimuth;
}

sub snr {
  my $self = shift();
  return $self->{'snr'};
}

sub used {
  my $self = shift();
  return $self->{'used'};
}

sub q2u {
  my $a=shift();
  return $a eq '?' ? undef() : $a;
}

1;
__END__

=pod

=head1 NAME

GPS::gpsd::satellite - Provides an interface for a gps satellite object.

=head1 SYNOPSIS

 #!/usr/bin/perl
 use strict;
 use GPS::gpsd;
 my $host = shift() || 'localhost';
 my $gps=GPS::gpsd->new(host=>$host) || die("Error: Cannot connect to the gpsd server");

 my $i=0;
 print join("\t", qw{Count PRN ELEV Azim SNR USED}), "\n";
 foreach ($gps->getsatellitelist) {
   print join "\t", ++$i,
                    $_->prn,
                    $_->elev,
                    $_->azim,
                    $_->snr,
                    $_->used;
   print "\n";
 }

=head1 DESCRIPTION

=head1 METHODS

=over

=item prn

Returns the Satellite PRN number.

=item elevation (aka elev)

Returns the satellite elevation, 0 to 90 degrees.

=item azimuth (aka azim)

Returns the satellite azimuth, 0 to 359 degrees.

=item snr

Returns the Signal to Noise ratio (C/No) 00 to 99 dB, null when not tracking.

=item used

Returns a 1 or 0 according to if the satellite was or was not used in the last fix.

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

GPS::gpsd::point

=cut
