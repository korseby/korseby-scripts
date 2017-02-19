#!/usr/bin/perl
# version: 1.1
#
# (c) Kristian Peters 2002-2003
# released under the terms of GPL
#
# changes: 1.1 - syntax
#
# contact: <kristian.peters@korseby.net>

# check for STDIN
if (! -t) {
	$stdin = true;
} else {
	$stdin = false;
}

# check for arguments
$args = "";
$c = 0;
for (@ARGV) {
	$args = $args . $ARGV[$c] . " ";
	$c++;
}

# print help
if ( ($stdin eq false) && ( ($#ARGV < 0) || ($#ARGV >= 2) || ($args =~ / -h/) || ($args =~ /^-h/) ) ) {
	die "Usage: random <inputfile> <outputfile>\n\nsend bug-reports to <kristian.peters\@korseby.net>\n";
}

# input file given
if ($stdin eq true) {
	@contents = <STDIN>;
} else {
	open(input, "<$ARGV[0]") or die "Error: Cannot find input file \"$ARGV[0]\".\n";
	@contents = <input>;
	close(input);
}

# output file given
$has_output = false;
if ($ARGV[1] ne "") {
	open(output, ">$ARGV[1]") or die "Error: Cannot open output file \"$ARGV[1]\" for writing.\n";
	$has_output = true;
}

# main loop
do {
	# count lines
	$numRecords = scalar(@contents);

	# take one line out of @contents randomly
	$index =int(rand($numRecords + 1));

	# print line
	$line = $contents[$index];
	if ($has_output == false) {
		print $line;
	} else {
		print output $line;
	}

	# delete line
	splice(@contents,$index,1);
} while ($numRecords ne 0);

# close output file if it was given
if ($has_output) {
	close(output);
}

