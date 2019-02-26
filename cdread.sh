#!/bin/bash
# version: 2.0
#
# (c) Kristian Peters 2003
# released under the terms of GPL
#
# changes: 2.0 - added new parameter structure (taken from mame-roms.sh)
#	   1.1 - bugfix (Apr 04 2003)
#          1.0 - initial release (Mar 08 2003)
#
# contact: <kristian.peters@korseby.net>

VERSION="2.0"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No iso-image given."
	elif [ "${1}" == "2" ] ; then
		echo "Error ${1}: iso-image not found."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "${0} creates an iso-image from a cd-rom."
	echo
	echo "Usage: ${0} <file.iso> [-d dev]"
	echo "e.g. ${0} cdrom.iso 0,0,0"
	echo
	echo "if no device \"dev\" was given the script assumes 0,0,0 which is the"
	echo "first cd-drive seen by cdrecord. (as \"cdrecord -scanbus\" shows)"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function check () {
	c=0
	l=0
	e=0
	if [ "${1}" != "" ] ; then
		for i in ${*}; do
			if [ "${l}" == "1" ] ; then
				COMMAND="${i}"
				return $[${c}-1]
			fi

			if [ "${c}" == "0" ] ; then
				echo -n ""
			elif [ "${i}" == "${1}" ] ; then
				l=1
			fi

			c=$[${c}+1]
		done
	else
		COMMAND=""
		for i in ${*}; do
			if [ "${l}" == "0" ] && [ "`echo ${i} | grep \-`" == "" ] ; then
				COMMAND="${COMMAND} ${i}"
				e=1
			fi

			if [ "`echo ${i} | grep \-`" != "" ] ; then
				l=1
			else
				l=0
			fi

			c=$[${c}+1]
		done
		return ${e}
	fi
}



mkimage () {
	echo
	readcd -v dev=${DEVICE} f=${IMAGE}
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	check "-d" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		DEVICE=${COMMAND}
		echo "User set device to ${DEVICE}."
	else
		DEVICE="0,0,0"
	fi

	check "" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		for i in ${COMMAND}; do
			IMAGE=${i}
			echo "reading to file ${IMAGE} ..."
			mkimage
		done
	else
		error 1
	fi
fi
