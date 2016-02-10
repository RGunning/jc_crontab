#!/usr/bin/env perl

use Modern::Perl;
use DateTime;
use DateTime::Format::DateParse;
use LWP::Simple;
use HTML::TableExtract;
use Cwd;
use Net::LDAP;


my $basedir = getcwd();
my ($friday_txt, $fourpm_text);
my ($presenter, $chair);
my $presenter2 ='';
my $chair2 = '';
my $location ='';
my ($te,@table,$nrows);
my $counter = 0;
my ($day_name, $time);

my $today = DateTime->today(time_zone => 'floating');
my $testing = shift @ARGV || 0; # set to 1 for testing mode

### SET CUSTOM DATE FOR TESTING
if ($testing){
	$today = DateTime->today(time_zone => 'floating');
	#$today = DateTime->new(	year => 2016, month => 2, day => 12); #Friday test
	#$today = DateTime->new(	year => 2016, month => 3, day => 3); #Thursday test
}

get_rota();

foreach my $rows (@table){
	$counter ++;
	next if $counter == 1; # has header row
	next if !($rows->[0]); # skip blank date
	$presenter = $rows->[4];
	$chair = $rows->[5];
 	$location = $rows->[1];

	my $dt = DateTime::Format::DateParse->parse_datetime( $rows->[0] );
	$time = $dt->hms(':');
	$time="16:00:00" if $time =~ "00:00:00";
	
 	$dt->truncate( to => 'day' );
	$day_name = $dt->day_name;

 	# work out if journal club is in 3/4 days (i.e. it is Friday and journal club is on Monday/Tuesday)
 	my $dur = $dt->subtract_datetime($today)->in_units('days');
 	

	if ( $today->day_name =~ 'Friday' && $dur <= 6 ) {
 		friday_email();
 		last;
 	}

 	# if journal club today (i.e. it is Monday)
 	if ( $dur == 0 ) {
 	 	# Get next event (Assume in sorted order)
 		if ($counter+1 <= $nrows) {
 			$presenter2 = $table[$counter]->[4];
 			$chair2 = $table[$counter]->[5];
 		}
 		monday_email();
 		last;
 	}
}

sub tele {
	my $name = shift;
	$name =~ s/-/ /g;
	my $ldap=Net::LDAP->new('ldap.internal.sanger.ac.uk') or die "$@";
	$ldap->bind;
	my $result = $ldap->search(
		base => "ou=people,dc=sanger,dc=ac,dc=uk",
		filter => "(&(sangerActiveAccount=TRUE)(sangerRealPerson=TRUE)(|(cn=*$name*)(givenName=*$name*)(uid=$name)(telephonenumber=$name)(roomNumber=$name)(departmentNumber=$name)))",
	);

	die $result->error if $result->code;
	my $resultscount = $result->count;

	my @uid;
	foreach my $entry ($result->entries) {
  	 	push @uid ,  ($entry->get_value("uid") || '');
	}

	# also search for "special" entries
	my $results2=$ldap->search(
		base=>'ou=tele,dc=sanger,dc=ac,dc=uk',
		filter=>"(cn=*$name*)",
	);
	$results2->code && die $results2->error;
	foreach my $entry ($results2->entries) {
  	 	push @uid ,  ($entry->get_value("uid") || '');
	}

	$resultscount += $results2->count;
	# if count >1 $result->count;

	$ldap->unbind;

	# What to do if count >1 $result->count;
	#return first element as email
	my $emailaddy = $uid[0] . "\@sanger.ac.uk";
	return $emailaddy;
}

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

sub monday_email {#
# 	#Send the 4PM email the day of the journal club, and alert the next presenter/host

 	# get text
 	email_text();

 	# Alert the next round of jc chiefs
 	my $next_presenter_email = tele($presenter2);
 	my $next_chair_email     = tele($chair2);

 	if (!$testing){
 		`echo "$fourpm_text" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -c dl5\@sanger.ac.uk -s \"Remember Journal Club TODAY\" phdjc\@sanger.ac.uk`;
 		`echo "Heads up! Next journal club will be headed by:\n$presenter2 as presenter\n$chair2 as chair\nThanks\nthe crontab ghost.\n" | mutt -s \"You're up next!\" $next_presenter_email $next_chair_email`;
 	} else {
  		say $fourpm_text;
  		say "$next_presenter_email $next_chair_email";
  		say "Heads up! Next journal club will be headed by:\n$presenter2 as presenter\n$chair2 as chair\nThanks\nthe crontab ghost.";
 	}
}

sub friday_email {
	# get text
	email_text();
	if (!$testing){
		`echo "$friday_txt" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -s \"Remember Journal Club $day_name\" phdjc\@sanger.ac.uk`;
	} else {
		say $friday_txt;
	}
}


sub email_text {
	$fourpm_text =  <<"EOF";
Dear Attendees,

This is a reminder to us that we are due to attend the PhD journal club in one
hour (at $time). Please don't forget to get hold of the paper and read it
over this one hour which is left if you still haven't done so.

Today's presenter: $presenter
Today's chair: $chair
Location: $location

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
$time on $day_name. Please don't forget to get hold of the paper and read
it over the weekend or on $day_name if you still haven't done so.

Monday's presenter: $presenter
Monday's chair: $chair

If you cannot make it for a good reason, please send your apologies to Annabel
<as11\@sanger.ac.uk> or Christina <chd\@sanger.ac.uk>.

thank you,
The Ghost of Sergei's crontab

https://helix.wtgc.org/groups/phd-journal-club
EOF

}
