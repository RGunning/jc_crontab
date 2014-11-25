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
my ($friday_txt, $fourpm_text);
my ($presenter, $chair, $presenter2, $chair2);
my $te;

my $today = DateTime->today();
#my $today = DateTime->new(	year => 2014, month => 11, day => 21); #Friday test

open DATES, $basedir ."/jc_dates.txt" or die "Can't open Dates file!";
#July 15, 2013	 C209/210	Regular	2011-12	 Florian Sessler	 Sam Behjati

# Does date file need renewed? Check last date against today
#get_rota();

while( my $line = <DATES>){
	chomp $line;
	my @fields = split "\t", $line;

	$presenter = $fields[4];
	$chair = $fields[5];

	my $dt = DateTime::Format::DateParse->parse_datetime( $fields[0] );
	$dt->truncate( to => 'day' );

	# if journal club is in 3 days (i.e. it is Friday)
	my $dtclone = $dt->clone();
	$dtclone->add( days => -3 );

	if ( $dtclone == $today ) {
		# Get next event
		friday_email();
		last;
	}

	# if journal club today (i.e. it is Monday)
	if ( $dt == $today ) {
		monday_email();
		last;
	}
}

sub get_email_from_name {
    my $name = shift;
    $name =~ s/-/ /g;
    my $query = `$basedir/my_tele.pl "$name" `;
    chomp $query;
    my $emailaddy = $query . "\@sanger.ac.uk";
    return $emailaddy;
}

sub get_rota {
	my $url = 'http://scratchy.internal.sanger.ac.uk/wiki/index.php/PhDJournalClub';
	my $html_string = get $url;
	die "Couldn't get $url" unless defined $html_string;
	open (my $fh, '>', $basedir.'jc_dates.txt') or die "Can't open file, $!\n";

	$te = HTML::TableExtract->new(count =>1 );
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
		my $line2 = <DATES>;
		chomp($line2);
		my @splat2 = split "\t", $line2;
		my $presenter2 = $splat2[4];
		my $chair2     = $splat2[5];

	# get text
	email_text();

	#`echo "$fourpm_text" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -c dl5\@sanger.ac.uk -s \"Remember Journal Club TODAY\" phdjc\@sanger.ac.uk`;

	# Alert the next round of jc chiefs
	my $next_presenter_email = get_email_from_name($presenter2);
	my $next_chair_email     = get_email_from_name($chair2);
	#`echo "Heads up! Next journal club will be headed by:\n$presenter2 as presenter\n$chair2 as chair\nSend out the voting poll in a few days.\nThanks\nthe crontab ghost.\n" | mutt -s \"You're up next!\" $next_presenter_email $next_chair_email`;


	say $fourpm_text;
	say "Heads up! Next journal club will be headed by:\n$presenter2 as presenter\n$chair2 as chair\nSend out the voting poll in a few days.\nThanks\nthe crontab ghost.";
}

sub friday_email {
	# get text
	email_text();
# 	`echo "$friday_txt" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -s \"Remember Journal Club MONDAY\" phdjc\@sanger.ac.uk`;
	say $friday_txt;
}


sub email_text {
	$fourpm_text =  <<"EOF";
Dear Attendees,

This is a reminder to us that we are due to attend the PhD journal club in one
hour (at 16:00). Please don't forget to get hold of the paper and read it
over this one hour which is left if you still haven't done so.

Today's presenter: $presenter
Today's chair: $chair

Next up: $presenter2 chaired by $chair2

If you cannot make it for a good reason, please send your apologies to Annabel
<as11\@sanger.ac.uk> or Christina <chd\@sanger.ac.uk> (which I think only
concerns people from Sanger Institute. If you are an EBI one - do not e-mail
Annabel or Christina, unless you want to be funny).

thank you,
The Ghost of Sergei's crontab

https://helix.wtgc.org/groups/phd-journal-club

EOF

	$friday_txt = <<"EOF";
Dear Attendees,

This is a reminder to us that we are due to attend the PhD journal club at
16:00 on Monday. Please don't forget to get hold of the paper and read
it over the weekend or on Monday if you still haven't done so.

Monday's presenter: $presenter
Monday's chair: $chair

If you cannot make it for a good reason, please send your apologies to Annabel
<as11\@sanger.ac.uk> or Christina <chd\@sanger.ac.uk>.

thank you,
The Ghost of Sergei's crontab

https://helix.wtgc.org/groups/phd-journal-club
EOF

}
