use ExtUtils::MakeMaker;
use File::Spec::Functions;

WriteMakefile(
    NAME            => 'Font::FreeType',
    AUTHOR          => 'Geoff Richards <qef@laxan.com>',
    VERSION_FROM    => 'lib/Font/FreeType.pm',
    LIBS            => [ `pkg-config --libs freetype2` ],
    INC             => `pkg-config --cflags freetype2`,
    NO_META         => 1,
);


# Generate a listing of the characters in the BDF test font, for checking
# that the library can find them all.  See t/10metrics_5x7bdf.t
my $data_dir = catdir(qw( t data ));
my $font_filename = catfile($data_dir, '5x7.bdf');
open my $font_file, '<', $font_filename
  or die "error opening BDF font '$font_filename': $!";
my $list_filename = catfile($data_dir, 'bdf_glyphs.txt');
open my $list_file, '>', $list_filename
  or die "error opening glyph listing file '$list_filename': $!";
my $name;
while (<$font_file>) {
    if (/^STARTCHAR\s+(.*)$/) {
        $name = $1;
        next;
    }
    elsif (/ENCODING\s+(\d+)$/) {
        die "BDF file is broken" unless defined $name;
        printf $list_file "%04X\t$name\n", $1;
        $name = undef;
    }
}

# vi:ts=4 sw=4 expandtab:
