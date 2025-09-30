#!/usr/bin/env bash
# version: 1.0
#
# (c) Kristian Peters 2023
# released under the terms of GPL
#
# changes: 1.0 - first release
#
# contact: <kristian@korseby.net>

RANDOM_ID="$(xxd -u -l 4 -p /dev/urandom)"
TMPFILE="/tmp/imsort_${RANDOM_ID}.tmp"
PARALLEL="$(which parallel)"
if [[ "${PARALLEL}" != "" ]]; then
	PARALLEL_CORES="$(parallel --number-of-cores)"
	echo -n > ${TMPFILE}
else
	echo "Error. No parallel detected."
	exit 2
fi



function help() {
	echo "${0} renames all image files based on their creation dates."
	echo
	echo "Usage: ${0} (directory)"
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	echo -n > ${TMPFILE}
	for i in $(find ${1} -name "IMG*" -print | sort); do
		echo "mv \"${i}\" \"$(dirname ${i})/\$(exiftool -SubSecCreateDate -DateTimeOriginal ${i} | head -n 1 | perl -pe 's/(.*\: |\+.*)//g' | perl -pe 's/( |\:|\.)/_/g')_$(basename ${i})\"" >> ${TMPFILE}
	done
	
	${PARALLEL} --jobs ${PARALLEL_CORES} --delay 0 --arg-file ${TMPFILE}
	
	echo -n > ${TMPFILE}
	COUNT=0
	for i in $(find ${1} -name "*IMG*" -print | sort); do
		COUNT=$((COUNT+1))
		echo "mv \"${i}\" \"$(dirname ${i})/IMG_$(printf %04d ${COUNT}).${i##*.}\"" >> ${TMPFILE}
	done
	
	${PARALLEL} --jobs ${PARALLEL_CORES} --delay 0 --arg-file ${TMPFILE}
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] || [ "${1}" == "" ]; then
	help
else
	if [[ ! -d ${1} ]]; then
		echo "Error. ${1} is not a directory."
		exit 3
	else
		process ${1}
	fi
fi


