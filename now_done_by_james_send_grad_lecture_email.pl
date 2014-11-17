#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;
use Date::Parse;


# What day is it today?
my @now_time = localtime(time);

open (GRAD_SCHED, "/nfs/users/nfs_d/dk6/training/jc_crontab/graduate_lecture_dates.txt") or die "$!\n";
while (<GRAD_SCHED>) {
	my @fields = split /\t/, $_;
	my ($lec_day,$lec_mon,$lec_yr) = (strptime($fields[0]))[3,4,5];
	# When it is grad lecture day, send the email
	if ( 
		$now_time[3] - $lec_day == 0 && 
		$now_time[4] - $lec_mon == 0 && 
		$now_time[5] - $lec_yr == 0
	){
		send_email($_);
	}
}

sub send_email {
	my $lecture_info = shift;
	my @fields = split /\t/, $lecture_info;
	my ($date, $room, $presenter, $topic) = @fields;
	my $body = format_grad_text($presenter,$topic);
	my $subject = "Remember Graduate Lecture TODAY in $room.";
#	`echo "$body" | mutt -s \"Remember Graduate Lecture TODAY in C202.\" dk6\@sanger.ac.uk`;
	`echo "$body" | mutt -b dk6\@sanger.ac.uk -c gradoffice\@sanger.ac.uk -c predoc\@ebi.ac.uk -s \"Remember Graduate Lecture TODAY in C202.\" phd12\@sanger.ac.uk`;
}

sub format_grad_text {
	my ($presenter, $topic) = @_;
	open (GRAD_TEXT, "/nfs/users/nfs_d/dk6/training/jc_crontab/grad_lecture_email.txt") or die "$!: can't find grad text file\n";
	my $text;
	while (<GRAD_TEXT>) {
		$text .= $_;
		$text =~ s/foo/$presenter/;
		$text =~ s/bar/$topic/;
	}
	return $text
}
