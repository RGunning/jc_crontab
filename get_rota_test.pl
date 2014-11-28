#!/usr/bin/env perl

use Modern::Perl;
use DateTime;
use DateTime::Format::DateParse;

use Data::Dumper;
use LWP::Simple;
use HTML::Parser;
use HTML::Entities;
use HTML::TableExtract;
use Cwd;

my ($te,@table,$nrows);

get_rota();

sub get_rota {
	my $url = 'http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub';
	my $html_string = get $url;
	die "Couldn't get $url" unless defined $html_string;

	$te = HTML::TableExtract->new(count =>1 );
	$te->parse($html_string);
	@table = $te->rows;
	$nrows = @table;
	foreach (@table){
		for my $i ( 0 .. 5){
			$_->[$i] =~ s/^ +|[\t]| +$//g;
		}
		$_->[0] =~ s/ Monday| Tuesday| Wednesday| Thursday| Friday| Saturday| Sunday//g;
	}
}

say Dumper @table;

