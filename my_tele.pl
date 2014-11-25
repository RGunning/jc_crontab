#!/usr/bin/env perl -w
# $Id: tele,v 1.9 2011-03-25 11:02:52 dh3 Exp $
# vi:ai:cindent:ts=4:sw=4

use Net::LDAP;

if($#ARGV != 0) {
	print "usage: tele search-string\n";
	exit(1);
}

$ldap=Net::LDAP->new('ldap.internal.sanger.ac.uk') or die "$@";
$mesg=$ldap->bind; # anonymous
$w=$ARGV[0];
$mesg=$ldap->search(base=>'ou=people,dc=sanger,dc=ac,dc=uk',
	filter=>"(&(sangerActiveAccount=TRUE)(sangerRealPerson=TRUE)(|(cn=*$w*)(givenName=*$w*)(uid=$w)(telephonenumber=$w)(roomNumber=$w)(departmentNumber=$w)))");
$mesg->code && die $mesg->error;
#print "returned ", $mesg->count, " entries\n";

@entries=$mesg->sorted('sn');

# also search for "special" entries
$mesg=$ldap->search(base=>'ou=tele,dc=sanger,dc=ac,dc=uk',
	filter=>"(cn=*$w*)");
$mesg->code && die $mesg->error;

push @entries, $mesg->entries;

format STDOUT =
@<<<<<<<<
$uid,
.

#foreach $entry ($mesg->entries) { $entry->dump; }
#foreach $entry ($mesg->entries) {
foreach $entry ($entries[0]) {
	$uid = $entry->get_value('uid') || "";
	write;
}

$mesg = $ldap->unbind;
