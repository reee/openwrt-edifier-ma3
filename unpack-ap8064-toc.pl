#!/usr/bin/perl
#
# unpack-ap8064-toc.pl -- Unpack AP8064 "MVUB" audio table of contents
#
# (C) 2024 Hajo Noerenberg
#
# Usage: unpack-ap8064-toc.pl <offset> <flashdump.bin>
#
# "MVUB" Offsets that have been observed in the wild: 0xb8000, 0x100000
#
#
# http://www.noerenberg.de/
# https://github.com/hn/linkplay-a31
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3.0 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
#

use strict;

my $o = hex( $ARGV[0] );
die("Invalid offset") unless ( $o > 42 );

my $f = $ARGV[1];
open( IF, "<$f" ) || die( "Unable to open input file '$f': " . $! );
binmode(IF);

print "\nWarning: Alpha Status, various things are unknown and/or wrong!\n\n";

# 4 bytes "MVUB" signature

my $buf;
seek( IF, $o, 0 );

read( IF, $buf, 4 ) == 4 || die;
my $pretty = $buf;
$pretty =~ s/[^[:print:]]/./g;
printf( "Signature: %s - %s\n\n", unpack( "H*", $buf ), $pretty );

die("Invalid signature") if ( $buf ne "MVUB" );

read( IF, $buf, 4 ) == 4 || die;

read( IF, $buf, 1 ) == 1 || die;
my $len = unpack( "C", $buf );

my @toc;

for my $i ( 1 .. $len ) {
    read( IF, $buf, 4 ) == 4 || die;
    $pretty = $buf;
    $pretty =~ s/[^[:print:]]/_/g;
    $pretty =~ s/ /_/g;

    read( IF, $buf, 4 ) == 4 || die;
    my $offset = unpack( "V", $buf );
    read( IF, $buf, 4 ) == 4 || die;
    my $length = unpack( "V", $buf );

    printf(
        "Toc %02d, Signature: %s - %s, Offset %6x, Length %5x\n",
        $i, unpack( "H*", $buf ),
        $pretty, $offset, $length
    );

    $toc[$i]{sig} = $pretty;
    $toc[$i]{off} = $offset;
    $toc[$i]{len} = $length;

}

for my $i ( 1 .. $#toc ) {
    my $outfile =
      sprintf( "%s-toc-%02d-%s-%x-%x.mp3", $f, $i, $toc[$i]{sig}, $toc[$i]{off}, $toc[$i]{len} );
    print $outfile . "\n";

    seek( IF, $toc[$i]{off}, 0 );
    read( IF, $buf, $toc[$i]{len} ) == $toc[$i]{len} || die;
    open( OF, ">$outfile" ) || die( "Unable to open output file '$outfile': " . $! );
    binmode(OF);
    print OF $buf;
    close(OF);
}

