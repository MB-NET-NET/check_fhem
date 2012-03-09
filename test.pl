#!/usr/bin/perl -w

require "./99_Taupunkt.pm";

my ($h, $t);
while (<>) {
	chop;
	($h, $t) = split;
	

	print "AF($h,$t) = " . calc_af($h, $t) . "\n";
}
