#Copyright (c) 2006 Michael R. Davis (mrdvt92)
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::gpsd;

use strict;
use vars qw($VERSION);
use IO::Socket;
use Time::HiRes qw(sleep); # allows real sleep vice int sleep

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
  my %param = @_;
  $self->host($param{'host'} || 'localhost');
  $self->port($param{'port'} || '2947');
}

sub register {
  my $self = shift();
  my %param = @_;
  my $sub=$param{'sub'} || die('Error: sub=>\&{} required');
  my $send=$param{'send'} || 'S';
  while (1) {
    my $data=$self->get($send);
    if ($data->{'S'}->[0] > 0) {
      &{$sub}($data);
      sleep 1; 
    }
  }
}

sub get {
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

1;
__END__

=head1 NAME

  GPS::gpsd is a module that provides a perl interface to the gpsd daemon. gpsd is an open source gps deamon from http://gpsd.berlios.de/.

=head1 SYNOPSIS

  use GPS::gpsd;
  $gps = new GPS::gpsd(  host    => 'localhost',
	  		 port      => 2947
                );
  my $fix=$gps->get('SP');

  or

  use GPS::gpsd;
  $gps->register(sub=>\&gpsd_handler,
                 send=>'SP');
  sub gpsd_handler {
    my $data=shift();
    print "Lat:". $data->{'P'}->[0]. " Lon:". $data->{'P'}->[1]. "\n";
  }


=head1 DESCRIPTION

  GPS::gpsd provides a very simple interface to gpsd daemon in perl scripts.
 
  For example the method get('SP') returns a hash reference like
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
my $data=$gps->get('SDPTVAEL');
my %fix=('?'=>"Error", 0=>"No Fix", 1=>"Fix", 2=>"DGPS-Corrected Fix");
print "gpsd.pm Version:", $gps->VERSION, "\n";
print "gpsd Version:", $data->{'L'}->[1], "\n";
print "Fix:", $data->{'S'}->[0], "=", $fix{$data->{'S'}->[0]}, "\n";
print "Lat:", $data->{'P'}->[0], " Lon:", $data->{'P'}->[1], "\n";
print "Host:", $gps->host, " Port:", $gps->port, "\n";

$gps->register(sub=>\&gpsd_handler,
               send=>'SDPTVAE');

sub gpsd_handler {
  my $data=shift();
  print join " ", "Fix", $data->{'S'}->[0], $data->{'P'}->[0], $data->{'P'}->[1], "\n";
}

=head1 AUTHOR

  Michael R. Davis, qw/gpsd michaelrdavis com/

=head1 SEE ALSO

  gpsd http tracker http://twiki.davisnetworks.com/bin/view/Main/GpsApplications
  gpsd home http://gpsd.berlios.de/

=cut
