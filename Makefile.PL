use ExtUtils::MakeMaker;

system('lsid','-V') && die <<"EOF";
Cannot find the LSF executables in the PATH
Before using this module, please install the LSF executables and ensure they are in the PATH 
EOF

WriteMakefile
(
    NAME => 'LSF',
    VERSION_FROM    => 'LSF.pm',
    (
        $] >= 5.6
        ? (ABSTRACT   => 'A perl API built on top of the Load Share Facility (LSF) command line tools from Platform Computing (platform.com)',
           AUTHOR     => 'Mark Southern (mark_southern@merck.com)')
        : ()
    ),
    PREREQ_PM => { 
                    IPC::Run    => 0.66,
                    Date::Manip => 5.40,
                 },
    'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'},
);
