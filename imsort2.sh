#!/usr/bin/env bash
# version: 2.2
#
# (c) Kristian Peters 2025
# released under the terms of GPL
#
# changes: 1.0 - first release
#          2.1 - preserve naming after IMG_0000 ...
#          2.2 - also recognize associated xmp files
#
# contact: <kristian@korseby.net>

IFS=$'\n'
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
	echo "${0} renames all image files with description in file name and associated xmp files based on their creation dates."
	echo
	echo "Usage: ${0} (directory)"
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	echo -n > ${TMPFILE}
	for i in $(find ${1} -name "*IMG*" -print | grep -v xmp | sort); do
		if [ -f "${i%.*}.xmp" ]; then
			echo -n "mv \"${i%.*}.xmp\" \"$(dirname ${i%.*}.xmp)/\$(exiftool -SubSecCreateDate -DateTimeOriginal \"${i}\" | head -n 1 | perl -pe 's/(.*\: |\+.*)//g' | perl -pe 's/( |\:|\.)/_/g')_$(basename ${i%.*}.xmp)\" && " >> ${TMPFILE}
		fi
		echo "mv \"${i}\" \"$(dirname ${i})/\$(exiftool -SubSecCreateDate -DateTimeOriginal \"${i}\" | head -n 1 | perl -pe 's/(.*\: |\+.*)//g' | perl -pe 's/( |\:|\.)/_/g')_$(basename ${i})\"" >> ${TMPFILE}
	done
	
	#cat $TMPFILE
	${PARALLEL} --jobs ${PARALLEL_CORES} --delay 0 --arg-file ${TMPFILE}
	
	echo -n > ${TMPFILE}
	COUNT=0
	for i in $(find ${1} -name "*IMG*" -print | grep -v xmp | sort); do
		COUNT=$((COUNT+1))
		if [ -f "${i%.*}.xmp" ]; then
			echo -n "mv \"${i%.*}.xmp\" \"$(dirname ${i%.*}.xmp)/IMG_$(printf %04d ${COUNT})$(basename ${i%.*}.xmp | perl -pe 's/.*\d\d\d\d//' | perl -pe 's/(.+)\..*/$1/' | perl -pe 's/\.\w\w\w$//').xmp\" && " >> ${TMPFILE}
		fi
		echo "mv \"${i}\" \"$(dirname ${i})/IMG_$(printf %04d ${COUNT})$(basename ${i} | perl -pe 's/.*\d\d\d\d//' | perl -pe 's/(.+)\..*/$1/' | perl -pe 's/\.\w{3,4}$//').${i##*.}\"" >> ${TMPFILE}
	done
	
	#cat $TMPFILE
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


