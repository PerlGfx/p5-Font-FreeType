# Render bitmaps from an outline font.

use strict;
use warnings;
use Test::More;
use File::Spec::Functions;
use Font::FreeType;

# Set this flag to write the test data out afresh, then check the output
# carefully.
my $WRITE_TEST_DATA = 0;

my @test = (
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 0 },
    { char => 'A', x_sz => 72, y_sz => 72, x_res => 72, y_res => 72, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 1 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 100, y_res => 100, aa => 0 },
    { char => 'A', x_sz => 8, y_sz => 8, x_res => 600, y_res => 600, aa => 0 },
);
plan tests => scalar @test;

my $data_dir = catdir(qw( t data ));

# Load the TTF file.
# Hinting is turned off, because otherwise the compile-time option to turn
# it on (if you've licensed the patent) might otherwise make the tests fail
# for some people.  This should make it always the same, unless the library
# changes the rendering algorithm.
my $vera = Font::FreeType->new->face(catfile($data_dir, 'Vera.ttf'),
                                     load_flags => FT_LOAD_NO_HINTING);

foreach (@test) {
    my $test_filename = join('.', sprintf('%04X', ord $_->{char}),
                             @{$_}{qw( x_sz y_sz x_res y_res aa )}) . '.pgm';
    $test_filename = catfile($data_dir, $test_filename);
    open my $bmp_file, ($WRITE_TEST_DATA ? '>' : '<'), $test_filename
      or die "error opening test bitmap data file '$test_filename': $!";
    $vera->set_char_size($_->{x_sz}, $_->{y_sz}, $_->{x_res}, $_->{y_res});
    my $glyph = $vera->glyph_from_char($_->{char});
    my $pgm = $glyph->bitmap_pgm($_->{aa} ? FT_RENDER_MODE_NORMAL
                                          : FT_RENDER_MODE_MONO);

    if ($WRITE_TEST_DATA) {
        warn "Writing fresh test file '$test_filename'.\n";
        print $bmp_file $pgm;
    }
    else {
        my $expected = do { local $/; <$bmp_file> };
        is($expected, $pgm, "PGM of character matches $test_filename");
    }
}

# vim:ft=perl ts=4 sw=4 expandtab:
