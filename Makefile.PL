use ExtUtils::MakeMaker;
WriteMakefile(
  NAME      => q{GPS::gpsd},
  VERSION_FROM => q{lib/GPS/gpsd.pm},
  PREREQ_PM => {
                 strict       => 0,
                 vars         => 0,
                 IO::Socket   => 0,
               },
               ($] >= 5.005 ? 
                 (
                   ABSTRACT_FROM => 'lib/GPS/gpsd.pm',
                 ) : ()
               ),
             );
