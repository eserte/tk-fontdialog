#!/usr/local/bin/perl -w
# -*- perl -*-

#
# $Id: FontDialog.pm,v 1.5 1998/08/25 23:30:44 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 1998 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: eserte@cs.tu-berlin.de
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

package Tk::FontDialog;

use Tk 800; # new font function

use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Tk::Toplevel);

Construct Tk::Widget 'FontDialog';

$VERSION = '0.02';

sub Populate {
    my($w, $args) = @_;

    require Tk::HList;
    require Tk::ItemStyle;
    
    $w->SUPER::Populate($args);
    $w->protocol('WM_DELETE_WINDOW' => ['Cancel', $w ]);

    $w->withdraw;

    if (exists $args->{-font}) {
	$w->optionAdd('*font' => delete $args->{-font});
    }
    my $dialog_font = $w->fontCreate($w->fontActual
				     ($w->optionGet("font", "*")));
    if (exists $args->{-initfont}) {
	$w->{'curr_font'} = $w->fontCreate($w->fontActual
					   (delete $args->{-initfont}));
    } else {
	$w->{'curr_font'} = $dialog_font;
    }

    my $bold_font       = $w->fontCreate($w->fontActual($dialog_font),
					 -weight => 'bold');
    my $italic_font     = $w->fontCreate($w->fontActual($dialog_font),
					 -slant => 'italic');
    my $underline_font  = $w->fontCreate($w->fontActual($dialog_font),
					 -underline => 1);
    my $overstrike_font = $w->fontCreate($w->fontActual($dialog_font),
					 -overstrike => 1);

    $w->Label
      (-text => 'Family:',
       -underline => 0,
       -font => $bold_font,
      )->grid(-column => 1, -row => 1,
	      -sticky => 'w');

    my $famlb = $w->Scrolled
      ('HList',
       -scrollbars => 'osoe',
       -selectmode => 'single',
       -bg => 'white',
       -browsecmd => sub { $w->UpdateFont(-family => $_[0]) },
      )->grid(-column => 1, -row => 2,
	      -rowspan => 4,
	      -sticky => 'nesw');
     $w->Advertise('family_list' => $famlb);

    $w->Label
      (-text => 'Size:',
       -underline => 0,
       -font => $bold_font,
      )->grid(-column => 2, -row => 1,
	      -sticky => 'w');

    my $sizelb = $w->Scrolled
      ('HList',
       -scrollbars => 'oe',
       -width => 3,
       -bg => 'white',
       -selectmode => 'single',
       -browsecmd => sub { $w->UpdateFont(-size => $_[0]) },
      )->grid(-column => 2, -row => 2,
	      -rowspan => 4,
	      -sticky => 'nesw');
    $w->Advertise('size_list' => $sizelb);

    my @fontsizes;
    if (exists $args->{-fontsizes}) {
	@fontsizes = @{ delete $args->{-fontsizes} };
    } else {
	@fontsizes = qw(0 2 3 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
			23 24 25 26 27 28 29 30 33 34 36 40 44 48 50 56 64 72);
    }
    my $curr_size = $w->fontActual($w->{'curr_font'}, -size);
    foreach my $size (@fontsizes) {
	$sizelb->add($size, -text => $size);
	if ($size == $curr_size) {
	    $sizelb->selectionSet($size);
	    $sizelb->see($size);
	}
    }

    my $weight = $w->fontActual($w->{'curr_font'}, -weight);
    my $wcb = $w->Checkbutton
      (-variable => \$weight,
       -font => $bold_font,
       -onvalue => 'bold',
       -offvalue => 'normal',
       -text => 'Bold',
       -underline => 0, 
       -command => sub { $w->UpdateFont(-weight => $weight) }
      )->grid(-column => 3, -row => 2, -sticky => 'w');
    my $slant = $w->fontActual($w->{'curr_font'}, -slant);
    my $scb = $w->Checkbutton
      (-variable => \$slant,
       -font => $italic_font,
       -onvalue => 'italic',
       -offvalue => 'roman',
       -text => 'Italic',
       -underline => 0,
       -command => sub { $w->UpdateFont(-slant => $slant) }
      )->grid(-column => 3, -row => 3, -sticky => 'w');
    my $underline = $w->fontActual($w->{'curr_font'}, -underline);
    my $ucb = $w->Checkbutton
      (-variable => \$underline,
       -font => $underline_font,
       -onvalue => 1,
       -offvalue => 0,
       -text => 'Underline',
       -underline => 0,
       -command => sub { $w->UpdateFont(-underline => $underline) }
      )->grid(-column => 3, -row => 4, -sticky => 'w');
    my $overstrike = $w->fontActual($w->{'curr_font'}, -overstrike);
    my $ocb = $w->Checkbutton
      (-variable => \$overstrike,
       -font => $overstrike_font,
       -onvalue => 1,
       -offvalue => 0,
       -text => 'Overstrike',
       -underline => 1,
       -command => sub { $w->UpdateFont(-overstrike => $overstrike) }
      )->grid(-column => 3, -row => 5, -sticky => 'w');

    my $c = $w->Canvas
      (-height => 36,
       -bg => 'white',
       -relief => 'sunken',
       -bd => 2,
      )->grid(-column => 1, -row => 6, -columnspan => 3,
	      -sticky => 'ew', -padx => 5, -pady => 5);
    $w->Advertise('sample_canvas' => $c);

    my $bf = $w->Frame->grid(-row => 7, -column => 1,
			     -columnspan => 3, -sticky => 'news');

    my $okb = $bf->Button
      (-text => 'OK',
       -underline => 0,
       -fg => 'green4',
       -font => $bold_font,
       -command => ['Accept', $w ],
      )->grid(-column => 0, -row => 0,
	      -sticky => 'ew', -padx => 5);
    my $applyb;
    # XXX evtl. in configure erledigne
    if ($args->{-applycmd}) {
	my $applycmd = delete $args->{-applycmd};
	$applyb = $bf->Button
	  (-text => 'Apply',
	   -underline => 0,
	   -fg => 'yellow4',
	   -font => $bold_font,
	   -command => sub { $applycmd->($w->ReturnFont($w->{'curr_font'})) },
	  )->grid(-column => 1, -row => 0,
		  -sticky => 'ew', -padx => 5);
    }
    my $cancelb = $bf->Button
      (-text => 'Cancel',
       -underline => 0,
       -fg => 'red',
       -font => $bold_font,
       -command => ['Cancel', $w ],
      )->grid(-column => 2, -row => 0,
	      -sticky => 'ew', -padx => 5);
    $bf->grid('columnconfigure', 3, -weight => 1.0);

    my $nicecb = $bf->Checkbutton
      (-text => 'Nicefonts',
       -underline => 0,
       -variable => \$w->{Configure}{-nicefont},
       -command => sub { $w->InsertFamilies; },
      )->grid(-column => 4, -row => 0,
	      -sticky => 'ew', -padx => 5);
    
    $w->grid('columnconfigure', 0, -minsize => 4);
    $w->grid('columnconfigure', 4, -minsize => 4);
    $w->grid('rowconfigure',    0, -minsize => 4);
    $w->grid('rowconfigure',    8, -minsize => 4);

    $w->bind('<f>' => sub { $famlb->focus });
    $w->bind('<s>' => sub { $sizelb->focus });

    $w->bind('<b>' => sub { $wcb->focus });
    $w->bind('<i>' => sub { $scb->focus });
    $w->bind('<u>' => sub { $ucb->focus });
    $w->bind('<v>' => sub { $ocb->focus });

    $w->bind('<o>'      => sub { $okb->invoke });
    $w->bind('<Return>' => sub { $okb->invoke });
    $w->bind('<a>'      => sub { $applyb->invoke }) if $applyb;
    $w->bind('<c>'      => sub { $cancelb->invoke });
    $w->bind('<Escape>' => sub { $cancelb->invoke });

    # XXX -subbg: ugly workaround...
    $w->ConfigSpecs
      (-subbg => [ 'PASSIVE', 'subBackground', 'SubBackground', 'white'],
       -nicefont => [ 'PASSIVE', undef, undef, 0],
       -sampletext => ['PASSIVE', undef, undef, 
		       'The Quick Brown Fox Jumps Over The Lazy Dog.'],
       -title => [ 'METHOD', undef, undef, 'Choose a font'],
       DEFAULT   => [ 'family_list' ],
      );

    $w->Delegates(DEFAULT => 'family_list');

    # according to the manpage, the fonts are only destroyed if the
    # last reference to them are destroyed, too
    # XXX disable for now
#    $w->fontDelete($dialog_font, 
#		   $bold_font, $italic_font,
#		   $underline_font, $overstrike_font);

    $w;
}

sub UpdateFont {
    my($w, %args) = @_;
    $w->fontConfigure($w->{'curr_font'}, %args) if scalar %args;
    $w->Subwidget('sample_canvas')->delete('font');
# XXX see below
#    $w->Busy;
    eval {
	$w->Subwidget('sample_canvas')->createText
	  (2, 18,
	   -anchor => 'w',
	   -text => $w->cget(-sampletext),
	   -font => $w->{'curr_font'},
	   -tags => 'font');
    };
#    $w->Unbusy;
}

sub Cancel {
    my $w = shift;
    $w->{Selected} = undef;
}

sub Accept {
    my $w = shift;
    $w->{Selected} = $w->{'curr_font'};
}

sub Show {
    my($w, @args) = @_;

    $w->transient($w->Parent->toplevel);
    my $oldFocus = $w->focusCurrent;
    my $oldGrab = $w->grab('current');
    my $grabStatus = $oldGrab->grab('status') if ($oldGrab);
    $w->grab;

    $w->InsertFamilies();
    $w->UpdateFont();
    # XXX ugly...
    $w->Subwidget('family_list')->configure(-bg => $w->cget(-subbg));
    $w->Subwidget('size_list')->configure(-bg => $w->cget(-subbg));
    $w->Subwidget('sample_canvas')->configure(-bg => $w->cget(-subbg));

    $w->Popup(@args); 
    $w->waitVisibility;
    $w->focus;
    $w->waitVariable(\$w->{Selected});

    eval {
	$oldFocus->focus if $oldFocus;
    };
    $w->grab('release');
    $w->withdraw;
    if ($oldGrab) {
	if ($grabStatus eq 'global') {
	    $oldGrab->grab('-global');
	} else {
	    $oldGrab->grab;
	}
    }

    $w->ReturnFont($w->{Selected});
}

sub ReturnFont {
    my($w, $var) = @_;
    if (defined $var) {
	my $ret = $w->fontCreate($w->font('actual', $var));
	$ret;
    } else {
	undef;
    }
}

sub InsertFamilies {
    my $w = shift;

# XXX Busy ist gefährlich ... anscheinend wird der alte grab nicht
# richtig gespeichert!
#    $w->Busy;
    eval {
	my $nicefont = $w->cget(-nicefont); # XXX name?
	my $curr_family = $w->fontActual($w->{'curr_font'}, -family);
	my $famlb = $w->Subwidget('family_list');
	$famlb->delete('all');
	my @fam = sort $w->fontFamilies;
	my $bg = $w->cget(-subbg);
	foreach my $fam (@fam) {
	    (my $u_fam = $fam) =~ s/\b(.)/\u$1/g;
	    my $f_style = $famlb->ItemStyle
	      ('text', 
	       ($nicefont ? (-font => "{$fam}") : ()),
	       -bg => $bg,
	      );
	    $famlb->add($fam, -text => $u_fam, -style => $f_style);
	    if ($curr_family eq $fam) {
		$famlb->selectionSet($fam);
		$famlb->see($fam);
	    }
	}
    };
#    $w->Unbusy;

}

# put some dirt into Tk::Widget...
package Tk::Widget;

# XXX Refont Canvases?
sub RefontTree {
    my ($w, %args) = @_;
    my $dbOption;
    my $value;
    my $font = $args{-font} or die "No font specified";
    eval { local $SIG{'__DIE__'}; $value = $w->cget(-font) };
    if (defined $value) {
	$w->configure(-font => $font);
    }
    if ($w->isa('Tk::Canvas') and $args{-canvas}) {
	foreach my $item ($w->find('all')) {
	    eval { local $SIG{'__DIE__'};
		   $value = $w->itemcget($item, -font) };
	    if (defined $value) {
		$w->itemconfigure($item, -font => $font);
	    }
	}
    }
    foreach my $child ($w->children) {
	$child->RefontTree(%args);
    }
}

1;

__END__

=head1 NAME

Tk::FontDialog - a font dialog widget for perl/Tk

=head1 SYNOPSIS

    use Tk::FontDialog;
    $font = $top->FontDialog->Show;

=head1 DESCRIPTION

Tk::FontDialog implements a font dialog widget. XXX

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item -font

=item -initfont

=item -fontsizes

=item -nicefont

=item -sampletext

=back

=head1 BUGS/TODO

  - better POD
  - XXX
  - ConfigSpecs handling is poor
    put at least -font into configspecs
  - run test, call dialog for 2nd time: immediate change of font?
  - better name for nicefont

=head1 SEE ALSO

L<Tk::font|Tk::font>

=head1 AUTHOR

Slaven Rezic <eserte@cs.tu-berlin.de>

=head1 COPYRIGHT

Copyright (c) 1998 Slaven Rezic. All rights reserved.
This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
