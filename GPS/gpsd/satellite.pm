#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd::satellite;

use strict;
use vars qw($VERSION);

$VERSION = sprintf("%d.%02d", q{Revision: 0.1} =~ /(\d+)\.(\d+)/);

sub list {
  my $self = shift();
  my $data = shift();
  my @data = @{$data->{'Y'}};
  shift(@data);
  my @list = ();
  foreach (@data) {
    #print "$_\n";
    push @list, $self->new(split " ", $_);
  }
  return @list;
}

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

=head1 NAME

  GPS::gpsd::satellite is an internal module that provides an object interface for a gps satellite report.

=head1 SYNOPSIS

  use GPS::gpsd;
  $gps = new GPS::gpsd(  host    => 'localhost',
	  		 port      => 2947
                );
  my $satellite=$gps->getsatellite(); #Is a GPS::gpsd::satellite object
  print $satellite->list, "\n";

=head1 DESCRIPTION

=over

=head1 GETTING STARTED

=head1 KNOWN LIMITATIONS

=head1 BUGS

  No known bugs.

=head1 EXAMPLES

=head1 AUTHOR

  Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

=cut
