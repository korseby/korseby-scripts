#!/bin/sh

NAME="rsync_installation_dir"
VERSION="1.1"

RSYNC="/opt/bin/rsync"

IFS="
"



function help() {
	echo "${0} does rsync data from this host to another host."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function process() {
	${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/Installation/ --rsh="ssh -p 22" "kristian@adlib:/Volumes/archive/Installation/"
}



if [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	process
fi
