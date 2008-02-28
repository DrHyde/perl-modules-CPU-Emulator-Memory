use 5.006;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'CPU::Emulator::Memory',
    VERSION      => 1.001,
    PREREQ_PM    => {
        'Scalar::Util' => 0,
        'IO::Scalar'   => 0
    }
);
