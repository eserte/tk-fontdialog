# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk;
use Tk::FontDialog;
$loaded = 1;
print "ok 1\n";

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
		       -font => $b->cget(-font),
		       -title => 'Schriftart?',
		       -applycmd => \&apply_font,
		      );

$bf = $top->Frame->pack;
$bf->Button(-text => 'OK',
	    -command => sub { print "ok 2\n";
			      $top->destroy;})->pack(-side => 'left');
$bf->Button(-text => 'Not OK',
	    -command => sub { print "not ok 2\n";
			      $top->destroy;})->pack(-side => 'left');

MainLoop;

sub apply_font {
    my $font = shift;
    if (defined $font) {
	$b->configure(-font => $font);
	$f->RefontTree(-font => $font, -canvas => 1);
    }
}
