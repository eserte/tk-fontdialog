# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk;
use Tk::FontDialog;

use if $] >= 5.008, charnames => ':full'; # XXX for alternative sample text

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

$loaded = 1;
my $ok = 1;
print "ok ". $ok++ . "\n";

$top=new MainWindow;

my $fd;
$b = $top->Button(-text => 'Choose Font',
		  -command => sub {
		      $font = $fd->Show;
		      apply_font($font);
		  })->pack;
$f = $top->Frame->pack;
$f->Label(-text => 'Test RefontTree 1')->pack;
$f2 = $f->Frame->pack;
$f2->Label(-text => 'Test RefontTree 2')->pack;
$c = $f2->Canvas(-width => 100, -height => 30)->pack;
$c->createText(0,0,-anchor => 'nw', -text => 'Canvas Text');

$fd = $top->FontDialog(-nicefont => 0,
		       #-font => $b->cget(-font),
		       -title => 'Schriftart?',
		       #-familylabel => '~Schriftfamilie;',
		       #-sizelabel => '~Größe:',
		       #-weightlabel => '~Fett',
		       #-slantlabel  => '~Italic',
		       #-underlinelabel => '~Unterstrichen',
		       #-overstrikelabel => '~Durchgestrichen',
		       #-applylabel => 'Ü~bernehmen',
		       #-cancellabel => '~Abbruch',
		       #-altsamplelabel => 'A~lternative',
		       -applycmd => \&apply_font,
		       -familylabel => 'Schrift~familie',
		       -fixedfontsbutton => 1,
		       -nicefontsbutton => 1,
		       ($Tk::VERSION >= 804 ? (-sampletext => "The quick brown fox jumps over the lazy dog.\nUnicode: Euro=\N{EURO SIGN}, C with acute=\N{LATIN SMALL LETTER C WITH ACUTE}, cyrillic sh=\x{0428}") : ()),
		      );

eval {
    my $fd2 = $top->FontDialog;
    $fd2->Show('-_testhack' => 1);
};
if ($@) { print "not " } print "ok " . $ok++ . "\n";


$bf = $top->Frame->pack;
$bf->Button(-text => 'OK',
	    -command => sub { print "ok $ok\n";
			      $top->destroy;})->pack(-side => 'left');
$bf->Button(-text => 'Not OK',
	    -command => sub { print "not ok $ok\n";
			      $top->destroy;})->pack(-side => 'left');

if ($ENV{BATCH}) {
    $top->after(1000, sub {
	$top->destroy;
    });
}

MainLoop;

sub apply_font {
    my $font = shift;
    if (defined $font) {
	$b->configure(-font => $font);
	$f->RefontTree(-font => $font, -canvas => 1);
    }
}
