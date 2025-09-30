#!/bin/bash

NAME="share_file_http"
VERSION="1.0"

FILE="${1}"
PORT="${2}"

if [[ "$1" == "" ]] || [[ "$2" == "" ]]; then
	echo "Start a webserver and share a file for download."
	echo ""
	echo "Usage: ${0} \"file\" \"port\""
else
	while true; do
		echo -e 'HTTP/1.1 200 OK\r\n'
		cat ${FILE} | nc -l ${PORT}
		sleep 1
	done
fi
