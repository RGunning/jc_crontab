#!/usr/bin/env perl

use Modern::Perl;
use LWP::Simple;
use HTML::Parser;
use HTML::Entities;
use HTML::TableExtract;


my $url = 'http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub';
my $html_string = get $url;
die "Couldn't get $url" unless defined $html_string;

open (my $fh, '>', 'jc_dates_tmp.txt') or die "Can't open file, $!\n";

#say $html_string;

my $te = HTML::TableExtract->new(count =>1 );
#my $te = HTML::TableExtract->new(headers =>['Date','Room','Type','Intake year','Presenter(s): Group 1','Chair'] );

$te->parse($html_string);

my $counter=0;
foreach my $row ($te->rows) {
    $counter++;
    if (!($counter==1)){
    	#remove tabs and spaces
    	$row = join(';', @$row);
    	$row =~ s/^[\t ]|[\t]//g;
    	$row =~ s/;/\t/g; # tab delimit

    	#remove days of week
    	$row =~ s/ Monday| Tuesday| Wednesday| Thursday| Friday| Saturday| Sunday//g;
    	say $fh $row;
    }
}




