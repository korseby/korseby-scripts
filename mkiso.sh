#!/bin/bash
# version: 1.3
#
# (c) Kristian Peters 2002-2006
# released under the terms of GPL
#
# changes: 1.3 - added -iso-level 4 and removed joliet from options
#          1.2 - some better options to mkisofs
#          1.1 - syntax
#
# contact: <kristian@korseby.net>

if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	echo "$0 creates an iso-image."
	echo
	echo "Usage: ${0} <title> <image.iso> <path> [copyright]"
	echo
	echo "you must specify an title, image.iso and a path."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
else
	if [ "${4}" == "" ] ; then
		copyright=""
	else
		copyright=" -p \"${4}\" -P \"${4}\"";
	fi

	echo
	mkisofs -V ${1} ${copyright} -iso-level 4 -r -o ${2} ${3}
	# joliet is disabled now (-J -joliet-long -jcharset iso8859-1)
fi

