#!/usr/bin/env perl

use Modern::Perl;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use HTML::TableExtract;
use Cwd;
use Net::LDAP;
use Data::Dumper;

my $basedir = getcwd();
my ($friday_txt, $fourpm_text);
my ($presenter, $chair);
my $presenter2 ='';
my $chair2 = '';
my $location ='';
my ($te,@table,$nrows);
my $counter = 0;
my $day_name;

my $today = DateTime->today();
my $testing = shift @ARGV || 0; # set to 1 for testing mode

### SET CUSTOM DATE FOR TESTING
if ($testing){
	$today = DateTime->today();
	#$today = DateTime->new(	year => 2014, month => 11, day => 21); #Friday test
	#$today = DateTime->new(	year => 2014, month => 11, day => 24); #Monday test
}

get_rota();

say Dumper @table;

sub get_rota {
	my $url = 'http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub';
	my $html_string = get $url;
	die "Couldn't get $url" unless defined $html_string;

	$te = HTML::TableExtract->new(count =>1 );
	$te->parse($html_string);
	@table = $te->rows;
	$nrows = @table; #count number of rows
	foreach (@table){
		for my $i ( 0 .. 5){ #for each cell of row
			next if (!defined $_->[$i]); # skip if blank cell
			$_->[$i] =~ s/^ +|[\t]| +$//g; # remove proceeding/trailing spaces
		}
		$_->[0] =~ s/ Monday| Tuesday| Wednesday| Thursday| Friday| Saturday| Sunday//g;
	}
}
