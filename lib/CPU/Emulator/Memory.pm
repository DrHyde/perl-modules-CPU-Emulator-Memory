# $Id: Memory.pm,v 1.1 2008/02/14 14:24:10 drhyde Exp $

package CPU::Emulator::Memory;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION = '1.0';

local $SIG{__DIE__} = sub {
    die(__PACKAGE__.": $_[0]\n");
};

=head1 NAME

CPU::Emulator::Memory - memory for a CPU emulator

=head1 SYNOPSIS

    my $memory = CPU::Emulator::Memory->new();
    $memory->poke(0xBEEF, ord('s'));
    
    my $value = $memory->peek(0xBEEF); # 115 == ord('s')

=head1 DESCRIPTION

This class provides a flat 64K array of values which you can 'peek'
and 'poke'.

=head1 METHODS

=head2 new

The constructor returns an object representing a flat 64K memory
space addressable by byte.  It takes two optional named parameters:

=over

=item file

if provided, will provide a disc-based backup of the
RAM represented.  This file will be read when the object is created
(if it exists) and written whenever anything is altered.  If no
file exists or no filename is provided, then memory is initialised
to all zeroes.  If the file exists it must be writeable and of the
correct size.

=item endianness

defaults to LITTLE, can be set to BIG.  This matters for the peek16
and poke16 methods.

=back

=cut

sub new {
    my($class, %params) = @_;
    my $bytes = chr(0) x 0x10000;
    if(exists($params{file})) {
        if(-e $params{file}) {
            $bytes = _readRAM($params{file}, 0x10000);
        } else {
            _writeRAM($params{file}, $bytes)
        }
    }
    return bless(
        {
            contents => $bytes,
            overlays => [],
            ($params{file} ? (file => $params{file}) : ()),
            endianness => $params{endianness} || 'LITTLE'
        },
        __PACKAGE__
    );
}

=head2 peek, peek8

This method takes a single parameter, an address from 0 to 0xFFFF.
It returns the value stored at that address, taking account of what
secondary memory banks are active.  'peek8' is simply another name
for the same function, the suffix indicating that it returns an 8
bit (ie one byte) value.

=head2 peek16

As peek and peek8, except it returns a 16 bit value.  This is where
endianness matters.

=cut

sub peek8 {
    my($self, $addr) = @_;
    $self->peek($addr);
}
sub peek16 {
    my($self, $address) = @_;
    # assume little-endian
    my $r = $self->peek($address) + 256 * $self->peek($address + 1);
    # swap bytes if necessary
    if($self->{endianness} eq 'BIG') {
        $r = (($r & 0xFF) << 8) + int($r / 256);
    }
    return $r;
}
sub peek {
    my($self, $addr) = @_;
    die("Address $addr out of range") if($addr< 0 || $addr > 0xFFFF);
    return ord(substr($self->{contents}, $addr, 1));
}

=head2 poke, poke8

This method takes two parameters, an address and a byte value.
The value is written to the address.

It returns 1 if something was written, or 0 if nothing was written.

=head2 poke16

This method takes two parameters, an address and a 16-bit value.
The value is written to memory as two bytes at the address specified
and the following one.  This is where endianness matters.

Return values are undefined.

=cut

sub poke8 {
    my($self, $addr, $value) = @_;
    $self->poke($addr, $value);
}
sub poke16 {
    my($self, $addr, $value) = @_;
    # if BIGendian, swap bytes, ...
    if($self->{endianness} eq 'BIG') {
        $value = (($value & 0xFF) << 8) + int($value / 256);
    }
    # write in little-endian order
    $self->poke($addr, $value & 0xFF);
    $self->poke($addr + 1, ($value >> 8));
}
sub poke {
    my($self, $addr, $value) = @_;
    die("Value $value out of range") if($value < 0 || $value > 255);
    die("Address $addr out of range") if($addr< 0 || $addr > 0xFFFF);
    $value = chr($value);
    substr($self->{contents}, $addr, 1) = $value;
    _writeRAM($self->{file}, $self->{contents})
        if(exists($self->{file}));
    return 1;
}

# input: filename, required size
# output: file contents, or fatal error
sub _read_file { 
    my($file, $size) = @_;
    local $/ = undef;
    open(my $fh, $file) || die("Couldn't read $file\n");
    my $contents = <$fh>;
    die("$file is wrong size\n") unless(length($contents) == $size);
    close($fh);
    return $contents;
}

sub _readROM { _read_file(@_); }

# input: filename, required size
# output: file contents, or fatal error
sub _readRAM {
    my($file, $size) = @_;
    my $contents = _read_file($file, $size);
    _writeRAM($file, $contents);
    return $contents;
}

# input: filename, data
# output: none, fatal on error
sub _writeRAM {
    my($file, $contents) = @_;
    open(my $fh, '>', $file) || die("Can't write $file\n");
    print $fh $contents || die("Can't write $file\n");
    close($fh);
}
