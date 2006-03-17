use ExtUtils::MakeMaker;
WriteMakefile(
  NAME      => q{GPS::gpsd},
  DISTNAME  => q{perl-GPS-gpsd},
  VERSION_FROM => q{gpsd.pm},
  PREREQ_PM => {
                 strict       => 0,
                 vars         => 0,
                 IO::Socket   => 0,
                 Math::Trig   => 1.03,
               },
               ($] >= 5.005 ? 
                 (
                   ABSTRACT_FROM => 'gpsd.pm',
                 ) : ()
               ),
             );
