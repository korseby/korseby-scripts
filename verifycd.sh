#!/bin/bash
# Version: 2.7
#
# (c) Kristian Peters 2003-2007
# released under the terms of GPL
#
# changes: 2.7 - md5 creation in list-dir, automount, some Mac fixes
#          2.6 - added NOMOUNT option
#          2.5 - renamed to verifyvd.sh, added dvd support, updated check functions
#          2.4 - Zeugs/CDs is now directory
#          2.3 - -d now /data/burn
#          2.2 - list-dir will change with different IDs
#          2.1 - added new parameter --md5
#          2.0 - added new parameter structure (taken from mame-roms.sh)
#          1.0 - bugfixes
#          0.3 - redesign, generic approach
#
# contact: <kristian.peters@korseby.net>

VERSION="2.7"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No ID given."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "${0} verifies a burned cd or dvd."
	echo
	echo "Usage: ${0} <ID> [-l list-dir] [-d files-dir] [--nomd5] [--mount]"
	echo "e.g. ${0} vidvd111 -l /home/kristian/Desktop/Zeugs/CDs/Video -d /data/burn"
	echo
	echo "if no list-dir was given the script assumes the one from the example."
	echo "if no files-dir was given the script assumes the one from the example."
	echo "if \"--nomd5\" is given, no md5sums will be created."
	echo "if \"--mount\" is given, /mnt/dvdrw will be (un)mounted."
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

			if [ "`echo ${i} | grep "\--[a-z]"`" != "" ] || [ "`echo ${i} | grep "\--[A-Z]"`" != "" ]; then
				l=0
			elif [ "`echo ${i} | grep "\-[a-z]"`" != "" ] || [ "`echo ${i} | grep "\-[A-Z]"`" != "" ]; then
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



function create_md5sum () {
	# ${1} == directory
	# ${2} == md5-file
	for i in "${1}"/*; do
		if [ -d "${i}" ] ; then
			create_md5sum "${i}" ${2}
		else
			md5sum "${i}" >> ${2} || exit 1
		fi
	done
}



function verify () {
	MOUNT="/mnt/cdrom"
	DEVICE="/dev/cdrom"

	SIZE="$(du -sk ${FILES_DIR}/${ID} | cut -d \	 -f 1)"

	if [ ${SIZE} -gt 1000000000 ] ; then
		MOUNT="/mnt/dvdrw"
		DEVICE="/dev/dvdrw"
	else
		MOUNT="/mnt/dvdrw"
		DEVICE="/dev/dvdrw"
	fi

	if [ "$(uname -s)" == "Darwin" ] ; then
		MOUNT="/Volumes/${ID}"
	fi

	if [ "${CHKSUM}" == "YES" ] ; then
		echo &&\
		echo "list.." &&\
		if [ "${NOMOUNT}" == "NO" ] ; then mount ${MOUNT}; else echo -n ""; fi &&\
		ls -R ${MOUNT} >> ${LIST_DIR}/${ID} &&\
		echo "md5sum.." &&\
		echo -n > /tmp/dvdrw.md5
		create_md5sum ${MOUNT} /tmp/dvdrw.md5
		if [ "${NOMOUNT}" == "NO" ] ; then umount ${MOUNT}; else echo -n ""; fi &&\
		echo "${FILES_DIR}/${ID} md5sum.." &&\
		echo -n > /tmp/orig.md5 &&\
		if [ "${NOMOUNT}" == "NO" ] ; then eject ${DEVICE}; else echo -n ""; fi &&\

		create_md5sum "${FILES_DIR}/${ID}" /tmp/orig.md5 &&\
		cat /tmp/dvdrw.md5 | cut -d\  -f 1 > /tmp/dvdrw.md5sum &&\
		cat /tmp/orig.md5 | cut -d\  -f 1 > /tmp/orig.md5sum &&\
		if [ "$(diff -u /tmp/orig.md5sum /tmp/dvdrw.md5sum)" != "" ] ; then
			echo -en "\a"
			echo "burned image does not match data on harddisk."
			echo "check \"diff -u /tmp/orig.md5sum /tmp/dvdrw.md5sum\"."
		else
			echo "md5sums ok, creating archive..."
			cp /tmp/orig.md5 ${LIST_DIR}/md5.${ID}
		fi
	else
		echo &&\
		echo "list.." &&\
		if [ "${NOMOUNT}" == "NO" ] ; then mount ${MOUNT}; else echo -n ""; fi &&\
		ls -R ${MOUNT} >> ${LIST_DIR}/${ID} &&\
		ls -R ${MOUNT} | sed -e "s%${MOUNT}%%g" > /tmp/dvdrw.lst
		if [ "${NOMOUNT}" == "NO" ] ; then umount ${MOUNT}; else echo -n ""; fi &&\
		if [ "${NOMOUNT}" == "NO" ] ; then eject ${DEVICE}; else echo -n ""; fi &&\
		echo "${FILES_DIR}/${ID} list.." &&\
		ls -R "${FILES_DIR}/${ID}" | sed -e "s%${FILES_DIR}/${ID}%%g" > /tmp/orig.lst &&\
		if [ "$(diff -u /tmp/orig.lst /tmp/dvdrw.lst)" != "" ] ; then
			echo -e "\a differences. burn maybe failed diff -u /tmp/orig.lst /tmp/dvdrw.lst "
		fi
	fi
}



if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help	
else
	check "-d" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		FILES_DIR=${COMMAND}
		echo "User set Files directory to ${FILES_DIR}."
	else
		FILES_DIR="/Volumes/misc/burn"
	fi

	check_simple "--nomd5" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		CHKSUM="NO"
		echo "User set checksumming."
	else
		CHKSUM="YES"
	fi

	check_simple "--mount" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		NOMOUNT="NO"
		echo "User set no mounting."
	else
		NOMOUNT="YES"
	fi

	check "" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		for i in ${COMMAND}; do
			ID=${i}
		done
	else
		error 1
	fi

	check "-l" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		LIST_DIR=${COMMAND}
		echo "User set List directory to ${LIST_DIR}."
	else
		TAG="$(echo ${ID} | cut -c 1-3)"
		if [ "${TAG}" == "vid" ] ; then
			LIST_DIR="/Users/kristian/Documents/CDs/Video"
		elif [ "${TAG}" == "mp3" ] ; then
			LIST_DIR="/Users/kristian/Documents/CDs/Musik"
		elif [ "${TAG}" == "Pro" ] || [ "${TAG}" == "OSX" ] ; then
			LIST_DIR="/Users/kristian/Document/CDs/Programme"
		elif [ "${TAG}" == "200" ] || [ "${TAG}" == "201" ] || [ "${TAG}" == "hom" ] ; then
			LIST_DIR="/Users/kristian/Documents/CDs/Home"
		else
			LIST_DIR="/Users/kristian/Documents/CDs/Video"
		fi
	fi

	echo "verifying ${ID} ..."
	echo $LIST_DIR
	verify
fi

