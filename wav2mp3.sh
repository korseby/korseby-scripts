#!/bin/bash
# version: 1.2
#
# (c) Kristian Peters 2002-2017
# released under the terms of GPL
#
# changes: 1.3 - added parallel compatibility
#          1.2 - small commandline changes
#          1.1 - syntax
#
# contact: <kristian@korseby.net>

TMPFILE="/tmp/wav2mp3.parallel.tmp"
PARALLEL="$(which parallel)"
if [[ "${PARALLEL}" != "" ]]; then
	PARALLEL_CORES="$(parallel --number-of-cores)"
	echo -n > ${TMPFILE}
fi



function help() {
	echo "${0} encodes all wav-files found to mp3."
	echo
	echo "Usage: ${0} [min bitrate] [max bitrate]"
	echo
	echo "audio files ending with *.wav must exist in the same directory"
	echo "from that ${0} was started from."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	if [ "${1}" == "" ] ; then
		for i in *.wav; do
			if [[ "${PARALLEL}" != "" ]]; then
				echo "lame -h -v -b 192 -B 256 \"${i}\" \"`basename "${i}" .wav`.mp3\"" >> ${TMPFILE}
			else
				lame -h -v -b 192 -B 256 \"${i}\" \"`basename "${i}" .wav`.mp3\"
			fi
		done
	elif [ "${2}" == "" ] ; then
		for i in *.wav; do
			if [[ "${PARALLEL}" != "" ]]; then
				echo "lame -h -v -b ${1} \"${i}\" \"`basename "${i}" .wav`.mp3\"" >> ${TMPFILE}
			else
				lame -h -v -b ${1} \"${i}\" \"`basename "${i}" .wav`.mp3\"
			fi
		done
	else
		for i in *.wav; do
			if [[ "${PARALLEL}" != "" ]]; then
				echo "lame -h -v -b ${1} -B ${2} \"${i}\" \"`basename "${i}" .wav`.mp3\"" >> ${TMPFILE}
			else
				lame -h -v -b ${1} -B ${2} \"${i}\" \"`basename "${i}" .wav`.mp3\"
			fi
		done
	fi
	
	if [[ "${PARALLEL}" != "" ]]; then
		${PARALLEL} --jobs ${PARALLEL_CORES} --delay 0 --arg-file ${TMPFILE}
	fi
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	process
fi


