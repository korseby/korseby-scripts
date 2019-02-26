#!/bin/bash

NAME="gronkhtv"
CHANNEL="twitch.tv/gronkhtv"
QUALITY="source"

OUTPUT_DIR="/Volumes/incoming/"
PLAYER="/Applications/Zusatzprogramme/VLC.app/Contents/MacOS/VLC"

OPTIONS="--loglevel info --stream-sorting source,best,medium,low --default-stream source --retry-streams 60 --retry-open 10 --hls-live-edge 6 --hls-segment-attempts 10 --hls-segment-threads 3 --hls-segment-timeout 5.0 --hls-timeout 10.0 --http-stream-timeout 20.0 --stream-segment-attempts 10 --stream-segment-threads 3 --stream-segment-timeout 5.0 --stream-timeout 10.0"



function help () {
	echo "${0} records a livestream to a file, player, or both."
	echo
	echo "Usage: ${0} [source|medium|low] [player|live]"
}



function process_live() {
	livestreamer ${OPTIONS} --verbose-player --player-passthrough hls --stdout ${CHANNEL} ${QUALITY} | tee >(cat - > "${OUTPUT_DIR}/twitch_${NAME}_$(date +%Y-%m-%d-%H%M%S).hls") | /Applications/Zusatzprogramme/VLC.app/Contents/MacOS/VLC -
}



function process() {
	livestreamer ${OPTIONS} -o "${OUTPUT_DIR}/twitch_${NAME}_$(date +%Y-%m-%d-%H%M%S).hls" ${CHANNEL} ${QUALITY}
}



if [[ "${1}" == "--help" ]] || [[ "${1}" == "-help" ]] || [[ "${1}" == "-h" ]] || [[ "${1}" == "-?" ]] ; then
	help
	exit
fi



if [[ "$@" =~ "medium" ]] ; then
	QUALITY="medium"
elif [[ "$@" =~ "low" ]] ; then
	QUALITY="low"
else
	QUALITY="source"
fi



if [[ "$@" =~ "player" ]] || [[ "$@" =~ "live" ]]; then
	process_live
else
	process
fi

