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
		echo "Error ${1}: No source or destination available."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "${0} makes a copy of a cd."
	echo
	echo "Usage: ${0} [-s speed] [-f src] [-t dst] [--simulate]"
	echo
	echo "if no speed was given it will burn with speed \"4\"."
	echo "if no device was given, \"0,0,0\" will automatically used as source-interface"
	echo "and \"0,1,0\" as dest.-interface."
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



function check_simple () {
	c=0
	e=0
	for i in ${*}; do
		if [ "${c}" == "0" ] ; then
			echo -n ""
		elif [ "${i}" == "${1}" ] ; then
			return ${c}
		fi

		c=$[${c}+1]
	done
	return 0
}



function copycd () {
	echo
	cdrdao copy ${SIMULATE} --source-device ${SRC} --device ${DST} --speed ${SEEP} --on-the-fly --buffers 128 --paranoia-mode 0 -v 3
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

	check "-f" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		SRC=${COMMAND}
		echo "User set source device to ${SRC}."
	else
		SRC="0,0,0"
	fi

	check "-d" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		DST=${COMMAND}
		echo "User set destination device to ${DST}."
	else
		DST="0,1,0"
	fi

	check_simple "--simulate" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		SIMULATE="--simulate"
		echo "User set simulation mode."
	else
		SIMULATE=""
	fi

	copycd
fi

