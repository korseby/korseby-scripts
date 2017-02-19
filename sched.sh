#!/bin/bash
# Version: 1.0
#
# (c) Kristian Peters 2006
# released under the terms of GPL
#
# changes: 1.0 - initial release
#
# contact: <kristian.peters@korseby.net>

VERSION="1.0"



function help () {
	echo "${0} runs a command at a specific time."
	echo
	echo "Usage: ${0} -t 23:00 -c command"
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



function schedule () {
	HS=$(echo "$TIME" | cut -d \: -f 1 | sed -e s/^0//)
	MS=$(echo "$TIME" | cut -d \: -f 2 | sed -e s/^0//)
	SCHED=0

	while [ "$SCHED" -eq "0" ]; do
		H=$(date +%H | sed -e s/^0//)
		M=$(date +%M | sed -e s/^0//)

		if [[ "$H" -eq "$HS" && "$M" -eq "$MS" ]] || [[ "${TIME}" == "now" ]]; then
			SCHED=1
			echo "$(date +%H:%M:%S): executing command..."
			exec "/home/kristian/Desktop/$RUNCOMMAND" "$RUNOPTIONS"
		fi

		sleep 1
	done
}



if [ "${1}" == "" ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
	help	
else
	check "-t" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		TIME=${COMMAND}
		if [ "${TIME}" != "now" ] ; then
			echo -n "will start at \"${TIME}\""
		else
			echo -n "will start now"
		fi
	else
		echo "wrong time format..."
		exit 2
	fi

	check "-c" ${*}
	RETURN=${?}
	if [ "${RETURN}" != "0" ] ; then
		RUNCOMMAND=${COMMAND}
		RUNOPTIONS=$(echo "${*}" | sed -e "s/.*${RUNCOMMAND} //")
		echo "the command \"${RUNCOMMAND}\" with \"$RUNOPTIONS\"."
	else
		echo "wrong command format..."
		exit 3
	fi

	schedule
fi

