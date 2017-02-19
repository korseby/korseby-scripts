#!/usr/bin/perl -w
use strict;
use MP3::Tag;
my $VERSION = "0.3";
my $NAME = "mp3eca.pl";
#
# (c) Kristian Peters 2006-2012
# released under the terms of GPL
#
# changes: 0.3 - removed bug that created empty files
#          0.2 - removed bug in / recognition in $curdir
#          0.1 - initial release
#
# contact: <kristian.peters@korseby.net>



# global variables
my $stdin = 0;
my $args = "";



# -------------------- help --------------------
sub help () {
	print("$NAME $VERSION extracts cover art out of mp3\n   and exports them to folder.jpg.\n\n");
	print("Usage: $NAME\n\n");
	print("$NAME takes NO argument, it simply processes all files and directories\n");
	print("in the current directory recursively and generates a folder.jpg in the\n");
	print("subdirectory. If folder.jpg already exists, it does nothing.\n\n");
	print("send bug-reports to <kristian.peters\@korseby.net>\n");
}



# -------------------- file_finder --------------------
sub process_file {
	my $file = $_[0];
	my $curdir = $_[0];
	my $mp3 = undef;
	my $frames = undef;

	# tricky: match last / in $curdir
	$curdir =~ s/[^\/]+$//;

	# only process, if no folder.jpg exists in current directory
	if ( ! -f "$curdir/folder.jpg") {
		$mp3 = MP3::Tag->new($file);
		$mp3->get_tags;

		if (exists $mp3->{ID3v2}) {
			$frames = $mp3->{ID3v2}->get_frame_ids();

			foreach my $frame (keys %$frames) {
				my $info = $mp3->{ID3v2}->get_frame($frame);
				next unless defined $info;
				if (ref $info) {
					while (my ($key,$val) = each %$info) {
						if ($key eq "_Data") {
							print("DATA to $curdir/folder.jpg\n");
							open FILE, ">$curdir/folder.jpg";
							print FILE $val;
							close FILE;
							exit 0;
						}
					}
				}
			}
		}
	}
}



# -------------------- file_finder --------------------
sub file_finder {
	my $dir = $_[0];
	my $searchstring = "$dir*";
	$searchstring =~ s/\\ / /g;
	$searchstring =~ s/ /\\ /g;
	my @files = glob("$searchstring");

	foreach (@files) {
		if ( -d $_ ) {
			# recurse into subdirectory
			file_finder("$_/");
		} else {
			# strip .mp3$ and process that file
			if ( $_ =~ /\.mp3$/ ) {
				my $file = $_;
				process_file($file);
			}
		}
	}
}



# -------------------- main program --------------------

# check for STDIN
if (! -t) {
	$stdin = 1;

	# convert string from STDIN to values
	@ARGV = <STDIN>;
	chomp(@ARGV);
} else {
	$stdin = 0;
}



# check for arguments
my $c = 0;
for (@ARGV) {
	$args = $args . $ARGV[$c] . " ";
	$c++;
}



# main loop
if ( ($args =~ / -h/) || ($args =~ /^-h/) || ($args =~ /--help/) ) {
	help();
} else {
	# find .kgen files and process them
	file_finder("./");
}
