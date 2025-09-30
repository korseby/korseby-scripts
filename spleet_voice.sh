#!/usr/bin/env bash
# version: 1.8
#
# (c) Kristian Peters 2019-2022
# released under the terms of GPL
#
# changes: 1.8 - detecting frame rate correctly
#          1.7 - update to spleeter 2.3.0
#          1.6 - make -s 120 as default and optimized _temp directory for space
#          1.5 - add with VLC compatible audio tracks, change default slice length from 320 to 240
#          1.4 - added random temp dir
#          1.3 - added parameters for method and slices length
#          1.2 - choose default method
#          1.1 - do not overload machine when there is less than 16 GB of RAM
#          1.0 - initial release
#
# contact: <kristian@korseby.net>

VERSION="1.8"

RANDOM_ID="$(xxd -u -l 4 -p /dev/urandom)"
TEMP_DIR="_temp-${RANDOM_ID}"



# Help
if [[ "${1}" == "-h" ]] || [[ "${1}" == "--help" ]] || [[ $# -eq 2 ]] || [[ $# -eq 4 ]] || [[ $# -gt 5 ]]; then
	echo "${0} grabs the audio track of a video file, extracts the voice"
	echo "using the tool spleeter and adds the voice-only track to the video again."
	echo ""
	echo "Usage: ${0} [-m spleeter:4stems] [-s 120] video.hls"
	echo ""
	echo "Options: (-m|-method) (spleeter:2stems|spleeter:4stems|spleeter:5stems)"
	echo "                       choose spleeting method"
	echo "         (-s|-slicelength) 120"
	echo "                       length of slices in seconds, 120 the default choice on 8GB RAM"
	echo ""
	echo "send bug-reports to <kristian@korseby.net>"
	exit 0
fi



# Check for binaries in PATH
if [[ "$(which ffprobe)" == "" ]] || [[ "$(which ffmpeg)" == "" ]] || [[ "$(which spleeter)" == "" ]]; then
	printf "\033[1;31mError:\033[0m No ffmpeg or spleeter binaries found.\n"
	exit 2
fi



# Exit when an error has occurred
function ERROR_EXIT() {
	printf "\033[1;31mError during processing\033[0m Exiting.\n"
	exit 3
}



# Variables
VIDEO="${@: -1}"
BASEDIR="$(dirname $VIDEO)"
DURATION="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${VIDEO})"
FRAMERATE="$(ffprobe -show_streams "${VIDEO}" 2>&1 | grep fps | awk '{split($0,a,"fps")}END{print a[1]}' | awk '{print $NF}')"
SLICE_LENGTH=120
METHOD="spleeter:4stems"
export NUMBA_CACHE_DIR="${TEMP_DIR}"



# Process arguments
while getopts m:method:s:slicelength: option; do
	case "${option}" in
		m|method) echo "Using method \"${OPTARG}\"..."; METHOD="${OPTARG}";;
		s|slicelength) echo "Using slicelength of \"${OPTARG}\"..."; SLICE_LENGTH="${OPTARG}";;
	esac
done

SLICES=$(echo $(awk "BEGIN { print (${DURATION} / ${SLICE_LENGTH}) - 1 }") | perl -pe 's/\..*//')



# Create temp directory
cd ${BASEDIR}
mkdir -p ${TEMP_DIR}



# Split audio into slices
ffmpeg -err_detect ignore_err -i ${VIDEO} -f segment -segment_time ${SLICE_LENGTH} -sn -vn -acodec copy ${TEMP_DIR}/%03d.aac || ERROR_EXIT

SLICES=$(ls ${TEMP_DIR}/*.aac | wc -l | perl -pe 's/\ |\t//g')



# Separate music and vocals with spleeter
#PARAMETER=""
#for ((i=0;i<${SLICES};i++)); do
#	PARAMETER="${PARAMETER} $(echo -n "${TEMP_DIR}/$(printf "%03d" "${i}").aac")"
#done
#for i in ${PARAMETER}; do
#	echo "Spleeting slice ${i}..."
#	spleeter separate ${i} -p ${METHOD} -o ${TEMP_DIR} || ERROR_EXIT
#done
spleeter separate ${TEMP_DIR}/*.aac -p ${METHOD} -o ${TEMP_DIR} || ERROR_EXIT



# Join audio files
PARAMETER=""
for ((i=0;i<${SLICES};i++)); do
	PARAMETER="${PARAMETER} $(echo -n "-i ${TEMP_DIR}/$(printf "%03d" "${i}").aac")"
done
ffmpeg -y ${PARAMETER} -filter_complex concat=n=${SLICES}:v=0:a=1 -f mp4 -vn ${TEMP_DIR}/_audio.mp4  || ERROR_EXIT



# Join spleeted audio files
PARAMETER=""
for ((i=0;i<${SLICES};i++)); do
	PARAMETER="${PARAMETER} $(echo -n "-i ${TEMP_DIR}/$(printf "%03d" "${i}")/vocals.wav")"
done
ffmpeg -y ${PARAMETER} -filter_complex concat=n=${SLICES}:v=0:a=1 -f mp4 -vn ${TEMP_DIR}/_vocals.mp4  || ERROR_EXIT



# Remove temporary audio files to save space
for ((i=0;i<${SLICES};i++)); do
	rm -rf "$(echo -n "${TEMP_DIR}/$(printf "%03d" "${i}")")"
done



# Test for streaming delays
DURATION_VIDEO="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${VIDEO})"
DURATION_AUDIO="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${TEMP_DIR}/_vocals.mp4)"
STREAM_DELAY="$(echo "${DURATION_VIDEO} ${DURATION_AUDIO}" | awk '{print $1 - $2}')"

# Add audio file to video
#ffmpeg -err_detect ignore_err -i ${VIDEO} -i ${TEMP_DIR}/_audio.mp4 -i ${TEMP_DIR}/_vocals.mp4 -map 0:v:0 -map 1:a:0 -map 2:a:1 -codec copy -shortest -bsf:a aac_adtstoasc -movflags faststart "$(basename ${VIDEO} .hls).mp4" || ERROR_EXIT
#ffmpeg -err_detect ignore_err -i ${VIDEO} -i ${TEMP_DIR}/_audio.mp4 -i ${TEMP_DIR}/_vocals.mp4 -map 0:v:0 -map 2:a:0 -map 1:a:0 -codec copy -shortest -bsf:a aac_adtstoasc -metadata:s:a:1 title="Original Audio" -metadata:s:a:0 title="Spleeted Audio" -movflags faststart "$(basename ${VIDEO} .hls).mp4" || ERROR_EXIT

# Add audio with delay
if echo ${STREAM_DELAY} | grep -qE '^[0-9]*\.?[0-9]+$'; then
	echo ""
	echo "AUDIO WITH DELAY: ${STREAM_DELAY}"
	ffmpeg -err_detect ignore_err -i ${VIDEO} -i ${TEMP_DIR}/_audio.mp4 -i ${TEMP_DIR}/_vocals.mp4 -itsoffset ${STREAM_DELAY} -i ${TEMP_DIR}/_vocals.mp4 -map 0:v:0 -map 3:a:0 -map 2:a:0 -map 1:a:0 -map 0:a:0 -codec copy -shortest -bsf:a aac_adtstoasc -metadata:s:a:3 title="Shifted Original Audio" -metadata:s:a:2 title="Shifted and Spleeted Audio" -metadata:s:a:1 title="Original Audio" -metadata:s:a:0 title="Spleeted Audio" -movflags faststart "$(basename ${VIDEO} .hls).mp4"
else
	ffmpeg -err_detect ignore_err -i ${VIDEO} -i ${TEMP_DIR}/_vocals.mp4 -map 0:v:0 -map 1:a:0 -map 0:a:0 -codec copy -shortest -bsf:a aac_adtstoasc -metadata:s:a:1 title="Original Audio" -metadata:s:a:0 title="Spleeted Audio" -movflags faststart "$(basename ${VIDEO} .hls).mp4"
fi



# Remove temporary files
rm -rf ${TEMP_DIR}


