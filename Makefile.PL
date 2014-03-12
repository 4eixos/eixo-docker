use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Eixo::Docker',
    VERSION_FROM      => 'lib/Eixo/Docker.pm', # finds $VERSION
    PREREQ_PM         => {
        'JSON' => "2.50",
        'LWP::UserAgent' => "5.0",
        'Net::HTTP'   => '6.06',
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (
          ABSTRACT         => 'Perl module to interact with Docker API', 
          AUTHOR           => '',
          TEST_REQUIRES     => {
              "HTTP::Server::Simple::CGI" => 0
          },
          BUILD_REQUIRES   => {
              "HTTP::Server::Simple::CGI" => 0
          },
      ): ()),
);
