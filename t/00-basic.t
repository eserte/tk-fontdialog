#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 00-basic.t,v 1.10 2005/10/21 21:42:54 eserte Exp $
# Author: Slaven Rezic
#

use strict;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

plan tests => 4;

use Tk;
use Tk::FontDialog;

my $sampletext;
BEGIN {
    eval q{
        use charnames ':full';
        $sampletext = "The quick brown fox jumps over the lazy dog.\nUnicode: Euro=\N{EURO SIGN}, C with acute=\N{LATIN SMALL LETTER C WITH ACUTE}, cyrillic sh=\x{0428}";
    };
    #warn $@;
}

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

pass("Module loaded");

my $top = new MainWindow;

my($b, $f, $fd);

$b = $top->Button(-text => 'Choose Font',
		  -command => sub {
		      my $font = $fd->Show;
		      apply_font($font);
		  })->pack;
{
    $f = $top->Frame->pack;
    $f->Label(-text => 'Test RefontTree 1')->pack;
    my $f2 = $f->Frame->pack;
    $f2->Label(-text => 'Test RefontTree 2')->pack;
    my $c = $f2->Canvas(-width => 100, -height => 30)->pack;
    $c->createText(0,0,-anchor => 'nw', -text => 'Canvas Text');
}

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
		       ($Tk::VERSION >= 804 && $sampletext ? (-sampletext => $sampletext) : ()),
		      );

my $fontname;
eval {
    my $fd2 = $top->FontDialog;
    $fontname = $fd2->Show('-_testhack' => $ENV{BATCH});
};
is($@, "", "No exceptions");

SKIP:
{
    skip("No font selected", 1) if (!defined $fontname);
    my $descriptive = $top->GetDescriptiveFontName($fontname);
    my %fa  = $top->fontActual($fontname);
    my %fa2 = $top->fontActual($descriptive);
    is_deeply(\%fa, \%fa2, "Same font");
}
    

my $bf = $top->Frame->pack;
my $okb = $bf->Button(-text => 'OK',
		      -command => sub {
			  pass();
			  $top->destroy;
		      }
		     )->pack(-side => 'left');
$bf->Button(-text => 'Not OK',
	    -command => sub {
		fail();
		$top->destroy;
	    }
	   )->pack(-side => 'left');

if ($ENV{BATCH}) {
    $top->after(1000, sub {
		    $okb->invoke;
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
