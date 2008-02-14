use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'CPU::Emulator::Memory',
    VERSION_FROM => 'lib/CPU/Emulator/Memory.pm',
    PREREQ_PM    => {
        # 'LWP::UserAgent' => 0,
    }
);
