#!/bin/sh
# version: 1.1
#
# (c) Kristian Peters 2006
# released under the terms of GPL
#
# changes: 1.1 - fixed grep ^- issue in function check
#          1.0 - initial release
#
# contact: <kristian.peters@korseby.net>

VERSION="1.0"



function error () {
	if [ "${1}" == "1" ] ; then
		echo "Error ${1}: No output file given."
	else
		echo "Error 0: Unknown error."
		${1}=255
	fi
	exit ${1}
}



function help () {
	echo "$0 records a movie from a v4l device."
	echo
	echo "Usage: ${0} <output.avi> [-h] [-c tv-channel]"
	echo
	echo "tv-channel is for example SE14, if none was given, the current will be used."
	echo "if -hq was supplied, high quality encoding will be used."
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
			if [ "${l}" == "0" ] && [ "`echo ${i} | grep ^-`" == "" ] ; then
				COMMAND="${COMMAND} ${i}"
				e=1
			fi

			if [ "`echo ${i} | grep ^-`" != "" ] ; then
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




function record_hq () {
	mencoder -tv driver=v4l:width=768:height=576 \
		-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=900:amode=0:adevice=/dev/dsp1 \
		-oac mp3lame -lameopts cbr:br=64 \
		-vf crop=720:544:24:16,pp=lb -o ${OFILE} tv://${TVCHANNEL}
}

function record_lq () {
	mencoder -cache 32768 -tv driver=v4l:width=768:height=576:amode=2:adevice=/dev/dsp1 \
		-ovc lavc -lavcopts vcodec=mjpeg:vbitrate=900:vqmax=31:keyint=250 \
		-oac mp3lame -lameopts fast:cbr:br=48:mode=3 \
		-vf crop=720:544:24:16,pp=lb,scale=416:312 -sws 0 -o ${OFILE} tv://${TVCHANNEL}
	#384:288
}



if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help
else
	check "-c" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		TVCHANNEL=${COMMAND}
		echo "User set tv-channel to ${TVCHANNEL}."
	else
		TVCHANNEL=""
	fi

	check_simple "-hq" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		HQ="YES"
		echo "Enabled High Quality Encoding"
	else
		RENAME="NO"
	fi

	check "" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		for i in ${COMMAND}; do			
			OFILE=${i}
			echo "Output file is ${OFILE} ..."
			if [ "${HQ}" != "YES" ] ; then
				record_lq
			else
				record_hq
			fi
		done
	else
		error 1
	fi
fi

