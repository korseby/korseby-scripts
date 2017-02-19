#!/bin/bash
# version: 1.0
#
# (c) Kristian Peters 2010
# released under the terms of GPL
#
# changes: 1.0 - initial release
#
# contact: <kristian.peters@korseby.net>

VERSION="1.0"
IFS="
"



function help () {
	echo "$0 splits up a single wav file by a cue file."
	echo
	echo "Usage: ${0} <name.wav> <name.cue>"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function cue_split () {
	wav_file="$1"
	cue_file="$2"
	
	bchunk -w $wav_file $cue_file _prefix
		
	prefix_names="$(cat "$cue_file" | grep TITLE | sed -e "s/.*TITLE \"//g" | sed -e"s/\"//g")"
	
	b=0
	for i in $prefix_names; do
		filename=$(echo $i | sed -e "s///g")
		if [ $b -gt 0 ] ; then
			if [ $b -lt 10 ] ; then
				mv "_prefix0${b}.wav" "0$b - $filename.wav"
			else
				mv "_prefix${b}.wav" "$b - $filename.wav"
			fi
		fi
		b=$[$b+1]
	done
}



if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
elif [ "${#}" -le 1 ] || [ "${#}" -gt 2 ] ; then
	echo "You must give exactly 2 arguments."
elif [ "$(which bchunk)" == "" ] ; then
	echo "Error: bchunk could not be found or is not in your PATH. Install it first."
else
	echo "Splitting up \"$1\" by \"$2\" ..."
	cue_split $1 $2
fi
