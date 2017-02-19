#!/bin/bash
# version: 1.0
#
# (c) Kristian Peters 2016-2017
# released under the terms of GPL
#
# changes: 1.0 - initial release
#
# contact: <kristian@korseby.net>

FLAC="$(which flac)"
if [[ "${FLAC}" != "" ]]; then
	METAFLAC="$(which metaflac)"
else
	echo "No flac found."
	exit 1
fi

TMPFILE="/tmp/flac2mp3.parallel.tmp"
PARALLEL="$(which parallel)"
if [[ "${PARALLEL}" != "" ]]; then
	PARALLEL_CORES="$(parallel --number-of-cores)"
	echo -n > ${TMPFILE}
fi



function help() {
	echo "${0} encodes all flac-files found to mp3."
	echo
	echo "Usage: ${0} [min bitrate] [max bitrate]"
	echo
	echo "Using min and max bitrate is not recommended anymore as lame chooses"
	echo "the best quality for the track anyway."
	echo
	echo "Audio files ending with *.flac must exist in the same directory"
	echo "from that ${0} was started from."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	# Modified from: https://wiki.archlinux.org/index.php/Convert_Flac_to_Mp3
	for i in *.flac; do
		# Change extension of output file
		OUTFILE="${i[@]/%flac/mp3}"
	
		# Get the tags
		ARTIST=$(${METAFLAC} "$i" --show-tag=ARTIST | sed s/.*=//g)
		TITLE=$(${METAFLAC} "$i" --show-tag=TITLE | sed s/.*=//g)
		ALBUM=$(${METAFLAC} "$i" --show-tag=ALBUM | sed s/.*=//g)
		GENRE=$(${METAFLAC} "$i" --show-tag=GENRE | sed s/.*=//g)
		TRACKNUMBER=$(${METAFLAC} "$i" --show-tag=TRACKNUMBER | sed s/.*=//g)
		DATE=$(${METAFLAC} "$i" --show-tag=DATE | sed s/.*=//g)
	
		# Output flac stream to lame
		if [ "${1}" == "" ] ; then
			if [[ "${PARALLEL}" != "" ]]; then
				echo "${FLAC} -c -d \"$i\" | lame -h -v -V0 --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta \"$ARTIST\" --tt \"$TITLE\" --tl \"$ALBUM\" --tg \"${GENRE:-12}\" --tn \"${TRACKNUMBER:-0}\" --ty \"$DATE\" - \"$OUTFILE\"" >> ${TMPFILE}
			else
				${FLAC} -c -d "$i" | lame -h -v -V0 --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta "$ARTIST" --tt "$TITLE" --tl "$ALBUM"  --tg "${GENRE:-12}" --tn "${TRACKNUMBER:-0}" --ty "$DATE" - "$OUTFILE"
			fi
		elif [ "${2}" == "" ] ; then
			if [[ "${PARALLEL}" != "" ]]; then
				echo "${FLAC} -c -d \"$i\" | lame -h -v -V0 -b \"${1}\" --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta \"$ARTIST\" --tt \"$TITLE\" --tl \"$ALBUM\" --tg \"${GENRE:-12}\" --tn \"${TRACKNUMBER:-0}\" --ty \"$DATE\" - \"$OUTFILE\"" >> ${TMPFILE}
			else
				${FLAC} -c -d "$i" | lame -h -v -V0 -b "${1}" --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta "$ARTIST" --tt "$TITLE" --tl "$ALBUM"  --tg "${GENRE:-12}" --tn "${TRACKNUMBER:-0}" --ty "$DATE" - "$OUTFILE"
			fi
		else
			if [[ "${PARALLEL}" != "" ]]; then
				echo "${FLAC} -c -d \"$i\" | lame -h -v -V0 -b \"${1}\" -B \"${2}\" --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta \"$ARTIST\" --tt \"$TITLE\" --tl \"$ALBUM\" --tg \"${GENRE:-12}\" --tn \"${TRACKNUMBER:-0}\" --ty \"$DATE\" - \"$OUTFILE\"" >> ${TMPFILE}
			else
				${FLAC} -c -d "$i" | lame -h -v -V0 -b "${1}" -B "${2}" --add-id3v2 --pad-id3v2 --ignore-tag-errors --ta "$ARTIST" --tt "$TITLE" --tl "$ALBUM"  --tg "${GENRE:-12}" --tn "${TRACKNUMBER:-0}" --ty "$DATE" - "$OUTFILE"
			fi
		fi
	done
	
	if [[ "${PARALLEL}" != "" ]]; then
		${PARALLEL} --jobs ${PARALLEL_CORES} --delay 0 --arg-file ${TMPFILE}
	fi
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	process
fi


