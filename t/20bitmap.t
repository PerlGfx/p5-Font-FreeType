# Extract bitmaps from a bitmap font.

use strict;
use warnings;
use Test::More tests => 3 * 3;
use File::Spec::Functions;
use Font::FreeType;

my ($WD, $HT) = (5, 7);

my $data_dir = catdir(qw( t data ));

# Load the BDF file.
my $bdf = Font::FreeType->new->face(catfile($data_dir, '5x7.bdf'));

# Load bitmaps from a file and compare them against ones from the font.
my $bmp_filename = catfile($data_dir, 'bdf_bitmaps.txt');
open my $bmp_file, '<', $bmp_filename
  or die "error opening test bitmap data file '$bmp_filename': $!";
while (<$bmp_file>) {
    /^(\d+)$/ or die "badly formated bitmap test file";
    my $unicode = $1;

    # Read test bitmap.
    my @expected;
    while (<$bmp_file>) {
        chomp;
        length == $WD or die "short line in bitmap test file";
        # It's easier to type spaces and hashes than these characters.
        s/ /\x00/g;
        s/#/\xFF/g;
        push @expected, $_;
        last if @expected == $HT;
    }

    my $glyph = $bdf->glyph_from_char_code(hex $unicode);
    my ($bmp, $left, $top) = $glyph->bitmap;
    is_deeply($bmp, \@expected);
    is($left, 0, 'bitmap starts 0 pixels to left of origin');
    is($top, 6, 'bitmap starts 6 pixels above origin');
}

# vim:ft=perl ts=4 sw=4 expandtab:
