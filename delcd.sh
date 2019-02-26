#!/bin/bash
# version 2.1
#
# (c) Kristian Peters 2002-2005
# released under the terms of GPL
#
# changes: 2.1 - added -force
#          2.0 - added new parameter structure (taken from mame-roms.sh)
#          1.1 - syntax, default mode fast
#
# contact: <kristian@korseby.net>

VERSION="2.1"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No blank mode given."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "${0} blanks a cd-rw."
	echo
	echo "Usage: ${0} <blankmode> [-s speed] [-d device]"
	echo
	echo "if no blank-mode was given it will use \"fast\"."
	echo "The following blank-modes are possible: all, fast, unclose, session"
	echo "if no device was given, \"0,1,0\" will automatically used as interface."
	echo
	echo "send bug-reports to <kristian@korseby.net>"
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



function blank () {
	echo
	cdrecord blank=help

	echo
	cdrecord blank=${BLANK} -force speed=${SPEED} dev=${DEVICE}

	sleep 30
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
			BLANK=${i}
			echo "Blanking with mode ${BLANK} ..."
			blank
		done
	else
		error 1
	fi
fi


