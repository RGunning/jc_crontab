#!/usr/bin/perl

use Date::Parse;

@time = localtime(time);

open DATES, "/nfs/users/nfs_r/rg12/jc_crontab/jc_dates.txt";

while(<DATES>){
	chomp;
	@splat = split "\t";
	# get the date string
	$splat[0] =~ s/"//g;
	@this_time = strptime($splat[0]);
	# Send the 4PM email the day of the journal club, and alert the next presenter/host
#	if(!($time[3] - $this_time[3]) && !($time[4] - $this_time[4]) && !($time[5] - $this_time[5])){
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
#       my $next_chair_email     = get_email_from_name($next_chair);
#		`echo "Heads up! Next journal club will be headed by:\n$next_presenter as presenter\n$next_chair as chair\nSend out the voting poll in a few days.\nThanks\nthe crontab ghost.\n" | mutt -s \"You're up next!\" $next_presenter_email $next_chair_email`;
#		last;
#	}
#	# Send the Friday email when the next Monday is jounal club
#	# Monday - x_Day = 3 when x_Day is Friday.
#	if(($this_time[3] - $time[3] == 3) && !($time[4] - $this_time[4]) && !($time[5] - $this_time[5])){
#		open TXT, "/nfs/users/nfs_r/rg12/jc_crontab/jc_friday.txt";
#		while(<TXT>){
#			$text .= $_;
#		}
#		close TXT;
#		$text =~ s/foo/$splat[4]/;
#		$text =~ s/bar/$splat[5]/;
#		`echo "$text" | mutt -c jr9\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -s \"Remember Journal Club MONDAY\" phdjc\@sanger.ac.uk`;
#		last;
#	}
}

sub get_email_from_name {
    my $name = shift;
    $name =~ s/-/ /g;
    my $query = `/nfs/users/nfs_r/rg12/jc_crontab/my_tele.pl "$name" `;
    chomp $query;
    my $emailaddy = $query . "\@sanger.ac.uk";
    return $emailaddy;
}
      
