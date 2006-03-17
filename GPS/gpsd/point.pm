#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd::point;

use strict;
use vars qw($VERSION);

$VERSION = sprintf("%d.%02d", q{Revision: 0.1} =~ /(\d+)\.(\d+)/);

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

=head1 NAME

  GPS::gpsd::point is an internal module that provides an object interface for a gps point.

=head1 SYNOPSIS

  use GPS::gpsd;
  $gps = new GPS::gpsd(  host    => 'localhost',
	  		 port      => 2947
                );
  my $point=$gps->get(); #$point is a GPS::gpsd::point object
  print $point->latitude;

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
