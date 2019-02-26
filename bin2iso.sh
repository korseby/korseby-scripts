#!/bin/bash
# version: 1.0
#
# (c) Kristian Peters 2004
# released under the terms of GPL
#
# changes: 1.0 - initial release
#
# contact: "Kristian Peters" <kristian.peters@korseby.net>

VERSION="1.0"



function help () {
	echo "${0} will convert a .bin-raw-image of a cd to iso-format."
	echo
	echo "Usage: ${0} <image.bin> <image.cue> <convert.iso>"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}


if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	if [ "${#}" -lt "3" ] ; then
		echo "You need 3 arguments. See --help."
		exit 1
	else
		bchunk "${1}" "${2}" "${3}"
	fi
fi

