#!/bin/sh

NAME="rsync_adlib_put"
VERSION="1.13"

RSYNC="/opt/bin/rsync"
USER="$(whoami)"

IFS=$'\n'



function help() {
	echo "${0} does rsync data from this host to another host."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function process_put() {
	if [[ "$USER" == "kristian" ]] || [[ "$USER" == "root" ]] ; then
		${RSYNC} --archive --xattrs --acls --ignore-errors --delete --delete-after --verbose --out-format="%o: %f (%b/%l)" --rsh="ssh -p 22" "/Users/kristian/Pictures/Lightroom" "kristian@10.12.6.98:/Users/kristian/Pictures/" 
	fi
}



if [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	process_put
fi


