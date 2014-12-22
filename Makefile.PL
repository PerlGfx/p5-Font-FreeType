use Devel::CheckLib;
use ExtUtils::MakeMaker;
use File::Spec::Functions;

my $inc = '-I/usr/include/freetype2';
my $lib = 'freetype';

check_lib_or_exit(
    lib    => $lib,
    INC    => $inc,
    header => 'ft2build.h',
);

WriteMakefile(
    NAME               => 'Font::FreeType',
    AUTHOR             => 'Geoff Richards <qef@laxan.com>',
    VERSION_FROM       => 'lib/Font/FreeType.pm',
    CONFIGURE_REQUIRES => {
        "Devel::CheckLib" => "0"
    },
    TEST_REQUIRES      => {
        Test::Warnings => 0,
    },
    LIBS               => "-l${lib}",
    INC                => $inc,
    ( eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
    ( eval { ExtUtils::MakeMaker->VERSION(6.46) } ?
        (
            META_MERGE => {
                resources => {
                    repository => 'https://github.com/zmughal/p5-Font-FreeType',
                },
            }
        ) : ()
    ),
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? ( MIN_PERL_VERSION => '5.8.1') : ()),
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
