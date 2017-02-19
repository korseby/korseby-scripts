#!/bin/bash
# version: 2.0
#
# (c) Kristian Peters 2002-2003
# released under the terms of GPL
#
# changes: 2.0 - added new parameter structure (taken from mame-roms.sh)
#          1.1 - syntax
#
# contact: <kristian.peters@korseby.net>

VERSION="2.0"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No toc-file given."
	elif [ "${1}" == "2" ] ; then
		echo "Error ${1}: toc-file not found."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "$0 burns a audio-cd from a given toc-file."
	echo
	echo "Usage: ${0} <music.toc> [-s speed] [-d device]"
	echo
	echo "if no speed was given it will burn with speed \"4\"."
	echo "if no device was given, \"0,1,0\" will automatically used as interface."
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



function burn () {
	echo
	if [ ! -f "${TOC_FILE}" ] ; then
		error 2
		exit 2
	fi

	cdrdao write --device ${DEVICE} --speed ${SPEED} ${TOC_FILE}
	echo "Waiting 40 seconds for ejecting..."
	sleep 40
	eject /dev/cdwriter
}

if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	check "-s" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		SPEED=${COMMAND}
		echo "User set speed to ${SPEED}."
	else
		SPEED="4"
	fi

	check "-d" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		DEVICE=${COMMAND}
		echo "User set device to ${DEVICE}."
	else
		DEVICE="0,1,0"
	fi

	check "" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		for i in ${COMMAND}; do
			TOC_FILE=${i}
			echo "Burning ${TOC_FILE} ..."
			burn
		done
	else
		error 1
	fi
fi

