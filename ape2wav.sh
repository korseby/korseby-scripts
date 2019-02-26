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

MPLAYER=false
MPLAYER_PATH="/Applications/Zusatzprogramme/MPlayerX.app/Contents/Resources/binaries/x86_64/"
IFS="
"



function help () {
	echo "$0 converts any ape file(s) to wav."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	if [ "$(which mplayer)" != "" ] ; then
		MPLAYER=true
		MPLAYER_PATH=""
	elif [ "$(which ${MPLAYER_PATH}mplayer)" == "" ] ; then
		echo "Error: The mplayer binary could not be found neither in your PATH nor in the mplayer dir."
		exit 1
	fi

	for i in *.ape; do
		filename="$(basename "$i" .ape)"
		file_ape="$i"
		file_wav="$filename.wav"
		echo "Converting $file_ape to $file_wav..."
		
		${MPLAYER_PATH}mplayer -vo null -vc dummy -af resample=44100 -ao pcm -ao pcm:waveheader "$i" -ao pcm:file="$file_wav"
	done
fi
