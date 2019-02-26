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
	echo "$0 creates a toc-file for a mixed-mode CD."
	echo
	echo "Usage: ${0}"
	echo
	echo "iso-images ending with *.iso and audio files ending with *.wav must exist"
	echo "in the same directory from that ${0} was started from."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
else
	echo
	echo "converting mp3->wav..."
	for i in *.mp3; do
		mpg123 -w "`basename "${i}" .mp3`.wav" "${i}" 2>/dev/null
	done

	echo "generating toc-file..."
	echo "// This file was created by Kristian" > mixedmode.toc
	echo "CD_ROM" >> mixedmode.toc

	echo "adding CD-ROM Track entries to toc-file..."
	c=0
	for i in *.iso; do
		c=$[c+1]
		CDROM="${i}"
	done
	if [ ${c} -gt "1" ] ; then
		echo "Warning: Multiple ISO-Tracks detected ! "
	fi
	echo "// Track 1 (CD-ROM)" >> mixedmode.toc
	echo "TRACK MODE1" >> mixedmode.toc
	echo "DATAFILE \"${CDROM}\"" >> mixedmode.toc
	echo "ZERO 00:02:00 // post-gap" >> mixedmode.toc
	echo "" >> mixedmode.toc

	echo "adding Audio Track entries to toc-file..."
	c=1
	for i in *.wav; do
		c=$[c+1]
		echo "// Track ${c} (Audio)" >> mixedmode.toc
		echo "TRACK AUDIO" >> mixedmode.toc
		if [ ${c} -eq "2" ] ; then
			echo "SILENCE 00:02:00 // pre-gap" >> mixedmode.toc
		else
			echo "NO COPY" >> mixedmode.toc
			echo "NO PRE_EMPHASIS" >> mixedmode.toc
			echo "TWO_CHANNEL_AUDIO" >> mixedmode.toc
		fi
		echo "START" >> mixedmode.toc
		echo "FILE \"${i}\" 00:00:00 " >> mixedmode.toc
		echo "" >> mixedmode.toc
	done
fi

