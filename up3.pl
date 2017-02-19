#!/usr/bin/perl
# version: 1.10
#
# (c) Kristian Peters 2003-2009
# released under the terms of GPL
#
# changes: 1.10 - minor updates
#          1.9 - little mac-fixes, new unicode umlaut changes
#          1.8 - new roman algorithm, little additions, roman is now always true
#          1.7 - roman numbers only via option
#          1.6 - roman numbers
#          1.5 - mac-umlauts, cleanup
#          1.4 - little additions
#          1.3 - some additions
#          1.2 - special characters, speed improvements
#          1.1 - some additions (umlauts, [ -> (, ...), bugfixes
#          1.0 - final changes
#          0.2 - added regexp's
#          0.1 - STDIN
#
# contact: <kristian.peters@korseby.net>

$VERSION="1.10";
$NAME="up3";



# check for STDIN
if (! -t) {
	$stdin = true;

	# convert string from STDIN to arguments
	@ARGV = <STDIN>;
	chomp(@ARGV);
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
if ( ($stdin eq false) && ( ($#ARGV < 0) || ($args =~ / -h/) || ($args =~ /^-h/) || ($args =~ /--help/) ) ) {
	die "$NAME gives mp3-files a proper format.\nOptions: -r   changes also roman characters to upper case\n\nUsage: $NAME [-r] <mask>\ne.g. $NAME *.mp3\n\nsend bug-reports to <kristian.peters\@korseby.net>\n";
}

# roman number checker
if ( ($args =~ /^-r/) || ($args =~ / -r/) )  {
	print "will NOT process roman characters..\n";
	$roman = false;
} else {
	$roman = true;
}

# main loop
for (@ARGV) {
	$orig = $_;

	# skipping option "-r"
	if ($orig eq "-r") {
		next;
	}

	# make whole line lower case
	$_ = lc($_);

	# change _ to " "
	$_ =~ s/_/ /g;

	# match any word at the beginning of a line ^\w
	#             or a word preceded by a whitespace \s\w
	#             or a word preceded by ( \(\w
	#             or a word preceded by [ \[\w
	$_ =~ s/((^\w)|(\s\w)|(\(\w)|(\[\w))/\U$1/g;

	# change to (
	$_ =~ s/(\[|\{)/\(/g;
	$_ =~ s/(\]|\})/\)/g;

	# change umlauts
	$_ =~ s/ä/ae/g;
	$_ =~ s/ö/oe/g;
	$_ =~ s/ü/ue/g;

	$_ =~ s/Ä/Ae/g;
	$_ =~ s/Ö/Oe/g;
	$_ =~ s/Ü/Ue/g;

	$_ =~ s/ß/ss/g;

	# change special characters
	$_ =~ s/(é|è|ê)/e/g;
	$_ =~ s/(á|à|â|æ)/a/g;
	$_ =~ s/(ó|ò|ô|ø)/o/g;
	$_ =~ s/(ú|ù|û)/u/g;
	$_ =~ s/(í|ì|î)/i/g;

	$_ =~ s/(É|È|Ê|¤)/E/g;
	$_ =~ s/(Á|À|Â|Æ)/A/g;
	$_ =~ s/(Ó|Ò|Ô|Ø)/O/g;
	$_ =~ s/(Ú|Ù|Û)/U/g;
	$_ =~ s/(Í|Ì|Î)/I/g;

	# change mac-umlauts
	$_ =~ s/aÌˆ/ae/g;
	$_ =~ s/oÌˆ/oe/g;
	$_ =~ s/uÌˆ/ue/g;

	$_ =~ s/AÌˆ/Ae/g;
	$_ =~ s/OÌˆ/Oe/g;
	$_ =~ s/UÌˆ/Ue/g;

	$_ =~ s/ÃŸ/ss/g;
	
	# change unicode umlauts
	$_ =~ s/(%e4|ai%88)/ae/g;
	$_ =~ s/(%f6|oi%88)/oe/g;
	$_ =~ s/(%fc|ui%88)/ue/g;
	$_ =~ s/%c4/Ae/g;
	$_ =~ s/%d6/Oe/g;
	$_ =~ s/%dc/Ue/g;
	$_ =~ s/%df/ss/g;

	# change unicode characters
	$_ =~ s/(%e0|%e1|%e2)/a/g;
	$_ =~ s/(%e5|%e8|%e9|%ea|I%a3|a%80%9a)/e/g;
	$_ =~ s/(%f2|%f3|%f4|%f8)/o/g;
	$_ =~ s/(%b5|%f9|%fa|%fb)/u/g;
	$_ =~ s/(%ec|%ed|%ee|i%83a%ad)/i/g;

	$_ =~ s/%c5/A/g;
	$_ =~ s/(%d8|Oi%88)/O/g;
	$_ =~ s/%e7/c/g;
	$_ =~ s/%c7/C/g;
	$_ =~ s/%a5/Y/g;

	$_ =~ s/(a|A)%80%93/-/g;
	$_ =~ s/(i%81|i%83|%92|%98|A%80%8e)//g;

	# other characters
	$_ =~ s/~/-/g;
	$_ =~ s/@/ at /g;
	$_ =~ s/°/o/g;
	$_ =~ s/ç/c/g;

	# remove bad characters
	$_ =~ s/(\'|\"|!|,|#|´|\$|\=)//g;

	# remove double spaces
	$_ =~ s/\ \ /\ /g;

	# change roman numbers
	if ($roman eq true) {
		@roman_list = ("Iii", "Ii", "Iv", "Ix", "Viii", "Vii", "Vi", "Xiii", "Xii", "Xix", "Xiv", "Xi", "Xv", "Xviii", "Xvii", "Xvi", "Xx");

		foreach $char (@roman_list) {
			$charup = $char;
			$charup = uc($char);
			$_ =~ s/((\s$char\s)|(\s$char\))|(\s$char\.))/\U$1/g;
		}
	}

	# special
	$_ =~ s/Dj\ /DJ\ /g;

	# change silly endings
	$_ =~ s/-(1real|4play|agc|atm|b(ass|np|cc|f|fhmp3|la|oss|pm)|chr|cm(c|g|s)|cqi|d(c|h)|doc|dps|drum|dxx|edn|ego|em(g|p)|esc|fnt|fs(o|t|p)|fwyh|gem|gg|gog|hit|hit2k|idc|its|j(ah|fk|mr)|just|k(ar|ouala|si|w)|m(bs|s|indtrip|px)|n(bd|vs)|k(inky|ouala)|obc|PsyCZ_NP|p(sycz|tc|ulse)|qdp|ri(ac|adial|fl)|s(b|fe|ge|iberia|ou(p|r)|ms)|tr|troni(k|k_int)|t(s|w)p|twc|u(be|dc|ki|t(e|b))|v2|vib3(s|z)|wqr|xds)\.mp3$/\.mp3/g;

	print "renaming \"$orig\" to \"$_\".\n";

	rename($orig,$_)
};
