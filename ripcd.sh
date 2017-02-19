#!/bin/bash
# version: 2.0
#
# (c) Kristian Peters 2002-2003
# released under the terms of GPL
#
# changes: 2.0 - added new parameter structure (taken from mame-roms.sh)
#          1.1 - syntax
#
# contact: <kristian@korseby.net>

VERSION="2.0"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No iso-image given."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "${0} rips a audio-cd."
	echo
	echo "Usage: ${0} [-d device] [-r range] [--rename]"
	echo
	echo "if no device was given, \"/dev/cdrom\" will automatically used"
	echo "as interface."
	echo "you can specify which tracks should be ripped by passing a string as"
	echo "last argument like \"1-\", \"4-6\" or \"4,5,7\"."
	echo "The option \"--rename\" toggles the rename-mode in which you can"
	echo "give the ripped tracks a proper filename."
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



function rip () {
	echo
	cdparanoia -vsQ -d ${DEVICE}
	cdparanoia -d ${DEVICE} -B ${RANGE}
}



function rename_tracks () {
	echo
	echo "You now have the chance to rename the just created tracks:"
	echo

	echo -n "Artist: "
	read ARTIST

	echo -n "Title: "
	read TITLE

	for i in *.wav; do
		TRACK="$(echo ${i} | sed -e "s/^track//" | sed -e "s/.cdda.wav//")"
		echo -n "${TRACK}: "
		read NAME
		mv "${i}" "${ARTIST} - ${TITLE} - ${TRACK} - ${NAME}.wav"
	done
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
		DEVICE="/dev/cdrom"
	fi

	check "-r" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		RANGE=${COMMAND}
		echo "User set range of ripped tracks to ${RANGE}."
	else
		RANGE="1-"
	fi

	check_simple "--rename" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		RENAME="YES"
		echo "User set rename-mode."
	else
		RENAME="NO"
	fi

	rip

	if [ "${RENAME}" != "NO" ] ; then
		rename_tracks
	fi
fi

