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

my $basedir = getcwd();

my $today = DateTime->today();
#my $today = DateTime->new(	year => 2014, month => 11, day => 21); #Friday test

open DATES, $basedir ."/jc_dates.txt" or die "Can't open Dates file!";
#July 15, 2013	 C209/210	Regular	2011-12	 Florian Sessler	 Sam Behjati

# Does date file need renewed? Check last date against today

while( my $line = <DATES>){
	chomp $line;
	my @fields = split "\t", $line;

	my $dt = DateTime::Format::DateParse->parse_datetime( $fields[0] );
	$dt->truncate( to => 'day' );

	# if journal club is in 3 days (i.e. it is Friday)
	my $dtclone = $dt->clone();
	$dtclone->add( days => -3 );
	if ( $dtclone == $today ) {

		friday_email;
		last;
	}

	# if journal club today (i.e. it is Monday)
	if ( $dt == $today ) {
		monday_emal;
		last;
	}
}

sub get_email_from_name {
    my $name = shift;
    $name =~ s/-/ /g;
    my $query = `/nfs/users/nfs_r/rg12/jc_crontab/my_tele.pl "$name" `;
    chomp $query;
    my $emailaddy = $query . "\@sanger.ac.uk";
    return $emailaddy;
}

sub get_rota {
	my $url = 'http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub';
	my $html_string = get $url;
	die "Couldn't get $url" unless defined $html_string;
	open (my $fh, '>', $basedir.'jc_dates.txt') or die "Can't open file, $!\n";

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
}

sub monday_email {
	#Send the 4PM email the day of the journal club, and alert the next presenter/host




#		open TXT, "/nfs/users/nfs_r/rg12/jc_crontab/jc_email.txt";
#		while(<TXT>){
#			$text .= $_;
#		}
#		close TXT;
#		$line2 = <DATES>;
#		chomp($line2);
#		@splat2 = split "\t", $line2;
#		my $next_presenter = $splat2[4];
#		my $next_chair     = $splat2[5];
#		$text =~ s/foo/$splat[4]/;
#		$text =~ s/bar/$splat[5]/;
#		$text =~ s/location/$splat[1]/;
#		$text =~ s/unique/$next_presenter/;
#		$text =~ s/term/$next_chair/;
#		`echo "$text" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -c dl5\@sanger.ac.uk -s \"Remember Journal Club TODAY\" phdjc\@sanger.ac.uk`;
#
#		# Alert the next round of jc chiefs
#		my $next_presenter_email = get_email_from_name($next_presenter);
      my $next_chair_email     = get_email_from_name($next_chair);
#		`echo "Heads up! Next journal club will be headed by:\n$next_presenter as presenter\n$next_chair as chair\nSend out the voting poll in a few days.\nThanks\nthe crontab ghost.\n" | mutt -s \"You're up next!\" $next_presenter_email $next_chair_email`;
#		last;
}



}

sub friday_email {
	open TXT, "/nfs/users/nfs_r/rg12/jc_crontab/jc_friday.txt";
	while(<TXT>){
		$text .= $_;
	}
	close TXT;
	$text =~ s/foo/$splat[4]/;
	$text =~ s/bar/$splat[5]/;
	`echo "$text" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -s \"Remember Journal Club MONDAY\" phdjc\@sanger.ac.uk`;
}

