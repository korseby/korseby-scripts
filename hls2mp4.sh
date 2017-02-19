#!/bin/sh
#
# (c) Kristian Peters 2016
# released under the terms of GPL



NAME="hls2mp4"
VERSION="1.0"

FFMPEG="$(which ffmpeg)"

IFS="
"



function help() {
	echo "${0} converts a hls stream to mp4"
	echo
	echo "Usage: ${0} [file1.hls file2.hls ...]"
	echo "       livestreamer | ${0} "
}



function process_live() {
	$FFMPEG -nostdin -i pipe:0 -c copy -bsf:a aac_adtstoasc stream_$(date +%Y-%m-%d-%H%M).mp4
}



function process() {
	OUTFILE=$(echo $i | sed -e "s/\.[^\.]*$//")
	$FFMPEG -i $i -c copy -bsf:a aac_adtstoasc ${OUTFILE}.mp4
}



if [ -t 1 ] ; then
	process_live	
elif [ "${1}" == "" ] || [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	for i in "$@"; do
		process $i
	done
fi

