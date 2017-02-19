#!/bin/bash
# version: 2.6
#
# (c) Kristian Peters 2002-2012
# released under the terms of GPL
#
# changes: 2.6 - mac changes
#          2.5 - added --verify (and autmatic verify for dvds)
#          2.4 - updated function check to match single --parameter
#          2.3 - added option -immed & -data, added parameter "--dummy"
#          2.2 - chache is now 32m, added -driveropts=burnfree option
#          2.1 - added "-overburn" option
#          2.0 - added new parameter structure (taken from mame-roms.sh)
#          1.1 - added fifo-buffer size of 16 MB
#
# contact: <kristian.peters@korseby.net>

VERSION="2.6"
EXITCODE="0"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No iso-image given."
	elif [ "${1}" == "2" ] ; then
		echo "Error ${1}: iso-image not found."
	else
		echo "${1}"
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "$0 burns a given iso-image with a given speed."
	echo
	echo "Usage: ${0} [-s speed] [-d device] [--overburn] [--dummy] [--verify] <image.iso>"
	echo
	echo "if no speed was given it will burn with speed \"8\"."
	echo "if no device was given, \"IODVDServices/1\" will used as interface."
	echo "--overburn lets you burn over the edge."
	echo "--dummy lets you test the burning operation."
	echo "--verify lets you test the burned image for consistency."
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



function burn () {
	echo
	if [ ! -f "${IMAGE}" ] ; then
		error 2
		exit 2
	fi

	imagesize="$(ls -Al ${IMAGE} | cut -d \  -f 5)"

#	if [ "${imagesize}" -gt "1000000000" ] ; then
#		DEVICE="1,0,0"
#		echo "image size is bigger than 1 GB. script set device to ${DEVICE}."
#		VERIFY="TRUE"
#		echo "enabled VERIFY."
#		echo ""
#	else
#		DEVICE="1,0,0"
#		VERIFY="TRUE"
#		SPEED="48"
#	fi

	echo -e "\n\\33[1;36mBeginning... \\33[0;39m"
	cdrecord -v -pad -dao ${OVERBURN} -driveropts=burnfree -fs=256m -immed -data ${DUMMY} speed=${SPEED} dev=${DEVICE} ${IMAGE}

	if [ "$VERIFY" == "TRUE" ] ; then
		# for speed enhancement, parralelizing in background
		echo -e "\n\\33[1;36mVerifying image... \\33[0;39m"
		md5sum ${IMAGE} > /tmp/burniso_md5_img &

		# note: burning adds some sectors filled with zeros at the end
		#       of the media (zero-padding)
		blocksize="$[${imagesize}/2048]"
		echo -e "\n\\33[1;36mVerifying with blocksize=${blocksize}... \\33[0;39m"
		readcd dev=${DEVICE} sectors=0-${blocksize} f=- | md5sum > /tmp/burniso_md5_rom

		md5_rom="$(cat /tmp/burniso_md5_rom | cut -d \  -f 1)"
		md5_img="$(cat /tmp/burniso_md5_img | cut -d \  -f 1)"
		if [ "${md5_rom}" != "${md5_img}" ] ; then
			echo -e "\a\n\\33[1;31mmd5 of burned media does not match image.\\33[0;39m"
			EXITCODE=3
		else
			echo -e "\a\n\\33[1;32memedia successfully burned.\\33[0;39m"
		fi
	fi

	cdrecord -silent -eject dev=${DEVICE} 2>&1 1>/dev/null
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
		SPEED="8"
	fi

	check "-d" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		DEVICE=${COMMAND}
		echo "User set device to ${DEVICE}."
	else
		DEVICE="1,0,0"
		#DEVICE="IODVDServices/1"
	fi

	check_simple "--overburn" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		OVERBURN="-overburn"
		echo "OVERBURNING ACTIVATED."
	else
		OVERBURN=""
	fi

	check_simple "--dummy" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		DUMMY="-dummy"
		echo "DUMMY operation."
	else
		DUMMY=""
	fi

	check_simple "--verify" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		VERIFY="TRUE"
		echo "VERIFYing enabled."
	else
		VERIFY="FALSE"
	fi

	check "" "${*}"
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		for i in ${COMMAND}; do
			IMAGE="${i}"
			echo "Burning ${IMAGE} ..."
			burn
		done
	else
		error 1
	fi

	exit ${EXITCODE}
fi

