# Metrics obtained from OldStandard-Bold.otf via by hand using ftdump
# from freetype v2.5.3

use strict;
use warnings;
use Test::More tests => 21;
use File::Spec::Functions;
use Font::FreeType;

my $data_dir = catdir(qw( t data ));

my $ft = Font::FreeType->new;
my $font = $ft->face(catfile($data_dir, 'OldStandard-Bold.otf'));
ok($font, 'FreeType->face() should return an object');
is(ref $font, 'Font::FreeType::Face',
    'FreeType->face() should return blessed ref');

# Test general properties of the face.
is($font->number_of_faces, 1, '$face->number_of_faces() is right');
is($font->current_face_index, 0, '$face->current_face_index() is right');

is($font->postscript_name, 'OldStandard-Bold',
    '$face->postscript_name() is right');
is($font->family_name, 'Old Standard',
    '$face->family_name() is right');
is($font->style_name, 'Bold',
    '$face->style_name() is right');

# Test face flags.
my %expected_flags = (
    has_glyph_names => 1,
    has_horizontal_metrics => 1,
    has_kerning => 0,
    has_reliable_glyph_names => 1,
    has_vertical_metrics => 0,
    is_bold => 1,
    is_fixed_width => 0,
    is_italic => 0,
    is_scalable => 1,
    is_sfnt => 1,
);

foreach my $method (sort keys %expected_flags) {
    my $expected = $expected_flags{$method};
    my $got = $font->$method();
    if ($expected) {
        ok($font->$method(), "\$face->$method() method should return true");
    }
    else {
        ok(!$font->$method(), "\$face->$method() method should return false");
    }
}

# Some other general properties.
is($font->number_of_glyphs, 1658, '$face->number_of_glyphs() is right');
is($font->units_per_em, 1000, '$face->units_per_em() is right');
is($font->underline_position, -198, 'underline position');
is($font->underline_thickness, 40, 'underline thickness');
#is($font->ascender, 952, 'ascender');
#is($font->descender, -294, 'descender');

