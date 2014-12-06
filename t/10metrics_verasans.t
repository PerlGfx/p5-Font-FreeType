# Metrics obtained from Vera.ttf by hand using PfaEdit
# version 08:28 11-Jan-2004 (040111).
#
# 268 chars, 266 glyphs
# weight class 400 (Book), width class medium (100%), line gap 410
# styles (SubFamily) 'Roman'

use strict;
use warnings;
use Test::More tests => 76 + 5 * 2 + 256 * 2;
use File::Spec::Functions;
use Font::FreeType;

my $data_dir = catdir(qw( t data ));

# Load the Vera Sans face.
my $ft = Font::FreeType->new;
my $vera = $ft->face(catfile($data_dir, 'Vera.ttf'));
ok($vera, 'FreeType->face() should return an object');
is(ref $vera, 'Font::FreeType::Face',
    'FreeType->face() should return blessed ref');

# Test general properties of the face.
is($vera->number_of_faces, 1, '$face->number_of_faces() is right');
is($vera->current_face_index, 0, '$face->current_face_index() is right');

is($vera->postscript_name, 'BitstreamVeraSans-Roman',
    '$face->postscript_name() is right');
is($vera->family_name, 'Bitstream Vera Sans',
    '$face->family_name() is right');
is($vera->style_name, 'Roman',
    '$face->style_name() is right');

# Test face flags.
my %expected_flags = (
    has_glyph_names => 1,
    has_horizontal_metrics => 1,
    has_kerning => 1,
    has_reliable_glyph_names => 0,
    has_vertical_metrics => 0,
    is_bold => 0,
    is_fixed_width => 0,
    is_italic => 0,
    is_scalable => 1,
    is_sfnt => 1,
);

foreach my $method (sort keys %expected_flags) {
    my $expected = $expected_flags{$method};
    my $got = $vera->$method();
    if ($expected) {
        ok($vera->$method(), "\$face->$method() method should return true");
    }
    else {
        ok(!$vera->$method(), "\$face->$method() method should return false");
    }
}

# Some other general properties.
is($vera->number_of_glyphs, 268, '$face->number_of_glyphs() is right');
is($vera->units_per_em, 2048, '$face->units_per_em() is right');
is($vera->underline_position, -284, 'underline position');
is($vera->underline_thickness, 143, 'underline thickness');
# italic angle 0
is($vera->ascender, 1901, 'ascender');
is($vera->descender, -483, 'descender');
is($vera->height, 2384, 'height');

# Test getting the set of fixed sizes available.
my @fixed_sizes = $vera->fixed_sizes;
is(scalar @fixed_sizes, 0, 'Vera has no fixed sizes');

subtest "charmaps" => sub {
    subtest "default charmap" => sub {
        my $default_cm = $vera->charmap;
        ok $default_cm;
        is $default_cm->platform_id, 3;
        is $default_cm->encoding_id, 1;
        is $default_cm->encoding, FT_ENCODING_UNICODE;
    };

    subtest "available charmaps" => sub {
        my $charmaps = $vera->charmaps;
        ok $charmaps;
        is ref($charmaps), 'ARRAY';
        is scalar(@$charmaps), 2;
    }
};

# Test iterating over all the characters.  256*2 tests.
# Note that this only gets us 256 glyphs, because there are another 10 which
# don't have corresponding Unicode characters and for some reason aren't
# reported by this, and another 2 which have Unicode characters but no glyphs.
# The expected Unicode codes and names of the glyphs are in a text file.
# TODO - how can we iterate over the whole lot?
my $glyph_list_filename = catfile($data_dir, 'vera_glyphs.txt');
open my $glyph_list, '<', $glyph_list_filename
  or die "error opening file for list of glyphs: $!";
$vera->foreach_char(sub {
    die "shouldn't be any argumetns passed in" unless @_ == 0;
    my $line = <$glyph_list>;
    die "not enough characters in listing file '$glyph_list_filename'"
      unless defined $line;
    chomp $line;
    my ($unicode, $name) = split ' ', $line;
    $unicode = hex $unicode;
    is($_->char_code, $unicode,
       "glyph $unicode char code in foreach_char()");
    is($_->name, $name, "glyph $unicode name in foreach_char()");
});
is(scalar <$glyph_list>, undef, "we aren't missing any glyphs");


# Test metrics on some particlar glyphs.
my %glyph_metrics = (
    'A' => { name => 'A', advance => 1401,
             LBearing => 16, RBearing => 17 },
    '_' => { name => 'underscore', advance => 1024,
             LBearing => -20, RBearing => -20 },
    '`' => { name => 'grave', advance => 1024,
             LBearing => 170, RBearing => 375 },
    'g' => { name => 'g', advance => 1300,
             LBearing => 113, RBearing => 186 },
    '|' => { name => 'bar', advance => 690,
             LBearing => 260, RBearing => 260 },
);

# Set the size to match the em size, so that the values are in font units.
$vera->set_char_size(2048, 2048, 72, 72);

# 5*2 tests.
foreach my $get_by_code (0 .. 1) {
    foreach my $char (sort keys %glyph_metrics) {
        my $glyph = $get_by_code ? $vera->glyph_from_char_code(ord $char)
                                 : $vera->glyph_from_char($char);
        die "no glyph for character '$char'" unless $glyph;
        local $_ = $glyph_metrics{$char};
        is($glyph->name, $_->{name},
           "name of glyph '$char'");
        is($glyph->horizontal_advance, $_->{advance},
           "advance width of glyph '$char'");
        is($glyph->left_bearing, $_->{LBearing},
           "left bearing of glyph '$char'");
        is($glyph->right_bearing, $_->{RBearing},
           "right bearing of glyph '$char'");
        is($glyph->width, $_->{advance} - $_->{LBearing} - $_->{RBearing},
           "width of glyph '$char'");
    }
}

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 57,
    AV => -131,
    'T.' => -243,
);

foreach my $pair (sort keys %kerning) {
    my ($kern_x, $kern_y) = $vera->kerning(
        map { $vera->glyph_from_char($_)->index } split //, $pair);
    is($kern_x, $kerning{$pair}, "horizontal kerning of '$pair'");
    is($kern_y, 0, "vertical kerning of '$pair'");
}

# Get just the horizontal kerning more conveniently.
my $kern_x = $vera->kerning(
    map { $vera->glyph_from_char($_)->index } 'A', 'V');
is($kern_x, -131, "horizontal kerning of 'AV' in scalar context");

# vim:ft=perl ts=4 sw=4 expandtab:
