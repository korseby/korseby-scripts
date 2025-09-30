#!/bin/bash
# version: 1.2
#
# (c) Kristian Peters 2016-2021
# released under the terms of GPL
#
# changes: 1.2 - use parallel and removing flac files by default
#          1.1 - bugfix
#          1.0 - initial release
#
# contact: <kristian@korseby.net>

FLAC="$(which flac)"
if [[ "${FLAC}" == "" ]]; then
	echo "Error! No flac found."
	exit 1
fi
FFMPEG="$(which ffmpeg)"
if [[ "${FFMPEG}" == "" ]]; then
	echo "Error! No ffmpeg found."
	exit 1
fi

TMPFILE="/tmp/flac2m4a.parallel.tmp"
PARALLEL="$(which parallel)"
if [[ "${PARALLEL}" != "" ]]; then
	PARALLEL_CORES="$(parallel --number-of-threads)"
	echo -n > ${TMPFILE}
fi



function help() {
	echo "${0} encodes all flac-files found to m4a (aka ALAC)."
	echo
	echo "Usage: ${0}"
	echo
	echo "Audio files ending with *.flac must exist in the same directory"
	echo "from that ${0} was started from."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	for i in *.flac; do
		# Change extension of output file
		OUTFILE="${i[@]/%flac/m4a}"
	
		# Output flac stream to m4a using ffmpeg
		if [[ "${PARALLEL}" != "" ]]; then
			echo "${FFMPEG} -y -i \"${i}\" -c:v copy -c:a alac \"${OUTFILE}\" && rm -f \"${i}\"" >> ${TMPFILE}
		else
			${FFMPEG} -y -i "${i}" -c:v copy -c:a alac "${OUTFILE}" && rm -f "${i}"
		fi
	done
	
	if [[ "${PARALLEL}" != "" ]]; then
		${PARALLEL} --jobs ${PARALLEL_CORES} --will-cite --delay 0 --arg-file ${TMPFILE}
	fi
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	process
fi

