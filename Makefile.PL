use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Tk::FontDialog',
    'VERSION_FROM' => 'FontDialog.pm', # finds $VERSION
    'PREREQ_PM' => {'Tk'             => 800},
    'dist'      => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},
);

sub MY::postamble {
    my $postamble = "";

    if (MY->can("oneliner")) {
	my $demo_oneliner = MY->oneliner("use blib; use Tk; use Tk::FontDialog; tkinit->FontDialog->Show");
	$postamble = <<EOF;
demo :: pure_all
	$demo_oneliner

EOF
    } elsif ($^O ne "MSWin32") {
	$postamble = <<'EOF';
demo :: pure_all
	$(FULLPERL) -w -Mblib -MTk -MTk::FontDialog -e 'tkinit->FontDialog->Show'

EOF
    }

    if (defined $ENV{USER} && $ENV{USER} eq 'eserte' && $^O =~ /bsd/i && -f "../../perl.release.mk") {
	$postamble .= <<'EOF';

.include "../../perl.release.mk"
.include "../../perl.cvs.mk"

EOF
    }

    $postamble;
}
