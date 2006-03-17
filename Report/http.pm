#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package Report::http;

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
  my $self=shift();
  my $data=shift();
  $data->{'url'}||='http://maps.davisnetworks.com/tracking/position_report.cgi';
  foreach (keys %$data) {
    $self->{$_}=$data->{$_};
  }
}

sub url {
  my $self = shift();
  if (@_) { $self->{'url'} = shift() } #sets value
  return $self->{'url'};
}

sub send {
  my $self=shift();
  my $data=shift(); #{}
  use LWP::UserAgent;
  my $ua=LWP::UserAgent->new();
  my $res = $ua->post($self->url, $data);
  return $res->is_success ? $res->content : undef();
}

1;
__END__

=pod

=head1 NAME

Report::http - Provides a perl interface to report position data. 

=head1 SYNOPSIS

 use Report::http;
 my $rpt=new Report::http();
 my $return=$rpt->send(\%data);

=head1 DESCRIPTION

=head1 METHODS

=over

=item new

=item send

=back

=head1 GETTING STARTED

=head1 KNOWN LIMITATIONS

=head1 BUGS

No known bugs.

=head1 EXAMPLES

=head1 AUTHOR

Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

gpsd http tracker http://twiki.davisnetworks.com/bin/view/Main/GpsApplications

gpsd home http://gpsd.berlios.de/

=cut
