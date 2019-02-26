#!/usr/bin/perl
my $VERSION="2.6";
my $NAME="setid3tag";
#
# (c) Kristian Peters 2003-2004
# released under the terms of GPL
#
# changes: 2.6 - function edit_id3: manually edit tags
#          2.5 - --leave is now standard, changed option to --no-leave
#          2.4 - bugfixes, added song from album without tracknumber
#          2.3 - recognizing single songs without tracknumber
#          2.2 - added leave mode
#          2.1 - filenames without title are recognized correctly
#          2.0 - improved recognization-routine for titles containing " - "
#          2.0-rc2 - improved recognizations for album, artist
#          2.0-rc1 - added force-mode
#          2.0-pre10 - added strip_id3
#          2.0-pre9 - added update_id3
#          2.0-pre8 - user can decide and won't be prompted on identical information
#          2.0-pre7 - added choice
#          2.0-pre6 - added function filename
#          2.0-pre5 - added global variables
#          2.0-pre4 - added check_title
#          2.0-pre3 - added regex for finding out the information in tags
#          2.0-pre2 - find_title implemented
#          2.0-pre1 - complete rewrite in perl
#          1.9 - added message that the shell-version is now depricated
#          1.8 - fixed bug in track-check
#          1.7 - fixed directory naming bug
#          1.6 - added error & warning mode
#          1.5 - better output
#          1.4 - fixed some delete bugs
#          1.3 - added --force option
#          1.2 - process also recursive
#          1.1 - id3 is now default, because it deletes/saves id3v1 & id3v2 tags
#                that others don't
#          1.0 - final changes
#          0.7 - added id3ed compatibility
#          0.6 - added id3ren compatibility
#          0.5 - added id3 compatibility
#          0.4 - added id3v2 compatibility
#          0.3 - added check_binary
#          0.2 - added functions
#          0.1 - initial release with sed & cut
#
# contact: <kristian.peters@korseby.net>



# definitions
my $LEAVE = 1;
my $STRIP = 0;
my $FORCE = 0;
my $DIRECTORY = ".";
my $ID3_BINARY = "/usr/bin/id3";

# variables
my $album  = "";
my $track  = "";
my $artist = "";
my $title  = "";

my $album_orig  = "";
my $track_orig  = "";
my $artist_orig = "";
my $title_orig  = "";




sub help () {
	print("$NAME changes the id3 tag of mp3s to match their filename.\n\n");
	print("Usage: $NAME [-d directory] [-b /path/to/id3] [--no-leave] [--strip] [--force]\n\n");
	print("if no directory was given, the script will proceed in the current.\n");
	print("you can specify an own id3-binary if it is not in /usr/bin.\n");
	print("if --strip was supplied, all id3 tags will be stripped out before\n");
	print("setting the tags.\n");
	print("--no-leave will also change mp3 with different id3 tags.\n");
	print("--force will give the mp3s an id3-tag even if errors are encountered.\n\n");
	print("The script will only look for id3. It must be installed on your system.\n\n");
	print("send bug-reports to <kristian.peters\@korseby.net>\n");
}



sub filename (@_) {
	my $line="@_";

	# strip out unwanted informatiom
	$line =~ s/.*\///g;
	$line =~ s/\.mp3//g;

	return $line;
}



sub strip_id3 (@_) {
	my @output = `$ID3_BINARY -d "$_" 2>&1`;
	my $exitcode = $?;
	if ($exitcode ne 0 ) {
		print("\n\nid3 crashed with errorcode $? and the following message:\n@output\n");
		print("[Press Return] ");
		my $answer = <STDIN>;
	}
}



sub check_title (@_) {
	my $file = filename(@_);

	my @output = `$ID3_BINARY -l "$_"`;
	
	# extract title information from output
	$title_orig = @output[1];
	$title_orig =~ s/.*Title  : //g;
	$title_orig =~ s/Artist: .*//g;
	$title_orig =~ s/ +?$//g;		# tricky: remove whitespaces at the end
	chomp($title_orig);

	# extract artist information
	$artist_orig = @output[1];
	$artist_orig =~ s/.*Artist: //g;
	$artist_orig =~ s/ +?$//g;
	chomp($artist_orig);
	
	# extract album information
	$album_orig = @output[2];
	$album_orig =~ s/.*Album  : //g;
	$album_orig =~ s/Year: .*//g;
	$album_orig =~ s/ +?$//g;
	chomp($album_orig);
	
	# extract track information
	$track_orig = @output[3];
	$track_orig =~ s/.*Track: //g;
	$track_orig =~ s/ +?$//g;
	chomp($track_orig);
}



sub find_title (@_) {
	my $line = filename(@_);
	my $file = $line;

	my @tags = ();
	my $fields = 0;
	my $position = -1;

	# sometimes tracknumbers are with letters instead of numbers
	$line =~ s/ - [ABCDEFGH](\d+?) - / - $1 - /g;
	$line =~ s/ - [ABCDEFGH](\d+?)$/ - $1/g;
	
	# put fields in line in @tags
	while (index($line," - ") ne -1) {
		push(@tags,substr($line,0,index($line," - ")));
		$line = substr($line,index($line," - ") + 3);
	}
	$fields = push(@tags,$line);

	# calculate position of tracknumber
	for (@tags) {
		$position++;
		if ($_/1) {
			#print "position of trackno at $position\n";
			last;
		}
	}

	# try to get album information out of filename
	$album  = "";
	if ($position ge 2 ) {
       		for ($c=1;$c lt ($position-1);$c++) {
			$album = "$album - $tags[$c]";
		}
	}
	$album  = "$album - $tags[$position-1]";
	$album =~ s/^ - //g;

	# try to get tracknumber
	$track  = $tags[$position];
	$track  =~ s/^0//g;

	# try to get artist information
	$artist = "";
	if ($position ge 2 ) {
       		$artist = "$tags[0]";
	} elsif ( ($position eq 1) && ($fields ge 4) ) { #(compilation)
		$artist = "$tags[$position+1]";
	}

	# get title information
	$title  = "";
       	for ($c=1;$c lt ($fields-$position);$c++) {
		$title = "$title - $tags[$position+$c]";
	}
	$title =~ s/^ - //g;
	
	# filename without tracknumber (special: single song)
	if ( ($position eq ($fields-1)) && ($fields eq 2) ) {
		$artist = $tags[0];
		$title  = $tags[1];
		$track  = "0";
		$album  = "";
	}
	
	# filename without tracknumber (special: single song from an album)
	if ( ($position eq ($fields-1)) && ($fields eq 3) && ($tags[2]*1 eq 0) ) {
		$artist = $tags[0];
		$title  = $tags[2];
		$track  = "0";
		$album  = $tags[1];
	}
}



sub choice (@_) {
	my $file = filename(@_);
	my $empty = 0;

	print("\n\n--------------------------------------------------------------------\n\n");
       	#system('/usr/bin/clear');
	print("$file\n\n");
	print("Artist: \"$artist\" ($artist_orig)\n");
	print("Album:  \"$album\" ($album_orig)\n");
	print("Track:  \"$track\" ($track_orig)\n");
	print("Title:  \"$title\" ($title_orig)\n");

	if ( ($artist_orig eq "") && ($album_orig eq "") && ($title_orig eq "") ) {
		print("\nEmpty headers detected...");
		$empty = 1;
	}
	
	if ( (($LEAVE eq 1 ) && ($empty eq 1)) || ($LEAVE eq 0) || ($FORCE eq 1) ) {
		if ( ($artist eq $artist_orig) && ($album eq $album_orig) && ($track eq $track_orig) && ($title eq $title_orig) ) {
			print("\nRename it ? [y|m|N] ");
			my $answer = <STDIN>;
			chomp($answer);

			if ( ($answer eq "M") || ($answer eq "m") ) {
				return 2;
			}
			elsif ( ($answer eq "Y") || ($answer eq "y") ) {
				return 1;
			}
		} else {
			print("\nRename it ? [Y|m|n] ");
			my $answer = <STDIN>;
			chomp($answer);

			if ( ($answer eq "M") || ($answer eq "m") ) {
				return 2;
			}
			elsif ( ($answer ne "N") && ($answer ne "n") ) {
				return 1;
			}
		}
	}
	
	return 0;
}



sub edit_id3 (@_) {
	print("\n\n");

	print("Artist: ");
	my $artist_new = <STDIN>;
	chomp($artist_new);

	print("Album: ");
	my $album_new = <STDIN>;
	chomp($album_new);
	
	print("Track: ");
	my $track_new = <STDIN>;
	chomp($track_new);
	
	print("Title: ");
	my $title_new = <STDIN>;
	chomp($title_new);

	print("\nUpdate tags ? [Y|a|n] ");
	my $answer = <STDIN>;
	chomp($answer);
	if ( ($answer eq "A") || ($answer eq "a") ) {
		return 2;
	}
	elsif ( ($answer ne "N") && ($answer ne "n") ) {
		$artist = $artist_new;
		$album  = $album_new;
		$track  = $track_new;
		$title  = $title_new;
		return 1;
	}

	return 0;
}



sub update_id3 (@_) {
	my @output = `$ID3_BINARY -a "$artist" -A "$album" -T "$track" -t "$title" "$_" 2>&1`;
	my $exitcode = $?;
	if ($exitcode ne 0 ) {
		print("\n\nid3 crashed with errorcode $? and the following message:\n@output\n");
		print("[Press Return] ");
		my $answer = <STDIN>;
	}
}



sub rename_mp3 (@_) {
	my $directory = "@_";
	$directory =~ s/ /\\ /g;	# bug?: perl does not recognize whitespaces in filenames
	my @files = glob("$directory/*");
	my $file = "";
	my $method = 0;

	for (@files) {
		$file="$_";
		if ( ! -e $file) {
			print ("WARNING: file \"$file\" does not exist.\n");
		} elsif ( -d $file ) {
			rename_mp3($file);
		} else {
			#print("$file\n");
			if ($file =~ /\.mp3$/) { #.mp3 at the end of the filename
				if ($STRIP eq 1) {
					strip_id3($file);
				}
				check_title($file);
				find_title($file);
				$method = choice($file);
				if ($method eq 2) {
					while (edit_id3($file) eq 2) {};
				}
				if ( ($method eq 1) || ($method eq 2) ) {
					update_id3($file);
				}
			}
		}
	}
}



# check for arguments
my $args = "";
my $c = 0;
for (@ARGV) {
	$args = $args . $ARGV[$c] . " ";
	$c++;
}

# print help
if ( ($#ARGV < 0) || ($args =~ / -h/) || ($args =~ /^-h/) || ($args =~ /--help/) ) {
	help();
} else {
	# get arguments from commandline
	if ($args =~ /--no-leave/) {
		print("User set leave mode to off.\n");
		$LEAVE = 0;
	}
	if ($args =~ /--strip/) {
		print("mp3 headers will be stripped before setting the tags.\n");
		$STRIP = 1;
	}
	if ($args =~ /--force/) {
		print("User set force mode to on.\n");
		$FORCE = 1;
	}
	
	# get DIRECTORY from command line
	if ($args =~ /-d /) {
		$c=0;
		for (@ARGV) {
			$c++;
			if ($ARGV[$c-1] eq "-d") {
				$DIRECTORY=$ARGV[$c];
				print("User set directory to \"$DIRECTORY\".\n");
				last;
			}
		}
	}

	# get ID3_BINARY from command line
	if ($args =~ /-b /) {
		$c=0;
		for (@ARGV) {
			$c++;
			if ($ARGV[$c-1] eq "-b") {
				$ID3_BINARY=$ARGV[$c];
				print("User set id3-binary to \"$ID3_BINARY\".\n");
				last;
			}
		}
	}
	
	# check for id3-binary existence
	if ( ! -e $ID3_BINARY) {
		die ("FATAL: id3-binary \"$ID3_BINARY\" does not exist.\n");
	} elsif ( ! -x $ID3_BINARY) {
		die ("FATAL: id3-binary \"$ID3_BINARY\" is not executable.\n");
	}
	
	# now: process with main function
	rename_mp3($DIRECTORY);
}
