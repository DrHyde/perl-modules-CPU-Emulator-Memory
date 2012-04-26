use 5.006;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'CPU::Emulator::Memory',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-CPU-Emulator-Memory'
        }
    },
    VERSION_FROM => 'lib/CPU/Emulator/Memory.pm',
    PREREQ_PM    => {
        'Scalar::Util' => 0,
        'IO::Scalar'   => 0,
        'IO::File'     => 0,
    }
);
