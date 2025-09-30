#!/bin/sh
# version: 1.1
#
# (c) Kristian Peters 2002-2003
# released under the terms of GPL
#
# changes: 1.1 - syntax
#
# contact: <kristian@korseby.net>

if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	echo "$0 prints a file via ghostscript and the driver ljet4."
	echo
	echo "Usage: ${0} <file1> <file2> ..."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
else
	gs -dNOPAUSE -dBATCH -sPAPERSIZE=a4 -sDEVICE=ljet4 -SOutputFile=/dev/lp0 -r300x300 ${*}
fi
