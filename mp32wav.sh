#!/bin/bash
# version: 1.1
#
# (c) Kristian Peters 2002-2003
# released under the terms of GPL
#
# changes: 1.1 - syntax
#
# contact: <kristian@korseby.net>

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	echo "${0} creates a toc-file for a Audio CD."
	echo
	echo "Usage: ${0}"
	echo
	echo "audio files ending with *.wav must exist in the same directory"
	echo "from that ${0} was started from."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
else
	echo
	echo "convert mp3->wav..."
	for i in *.mp3; do
		mpg123 -w "`basename "${i}" .mp3`.wav" "${i}" 2>/dev/null
	done

	echo "generating toc-file..."
	echo "// This file was created by Kristian" > music.toc
	echo "CD_DA" >> music.toc
	c=0
	for i in *.wav; do
		c=$[c+1]
		echo "// Track ${c}" >> music.toc
		echo "TRACK AUDIO" >> music.toc
		echo "NO COPY" >> music.toc
		echo "NO PRE_EMPHASIS" >> music.toc
		echo "TWO_CHANNEL_AUDIO" >> music.toc
		echo "START" >> music.toc
		echo "FILE \"${i}\" 00:00:00 " >> music.toc
		echo "" >> music.toc
	done
fi

