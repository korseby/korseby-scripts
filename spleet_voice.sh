#!/usr/bin/env bash

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] || [[ $# -ne 1 ]]; then
	echo "${0} grabs the audio track of a video file, extracts the voice"
	echo "using the tool spleeter and adds the voice-only track to the video again."
	echo ""
	echo "Usage: ${0} video.hls"
	echo ""
	echo "send bug-reports to <kristian@korseby.net>"
	exit 0
fi

VIDEO="${1}"
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${VIDEO})
SLICE_LENGTH=600
SLICES=$(echo $(awk "BEGIN { print ${DURATION} / ${SLICE_LENGTH} }") | perl -pe 's/\..*//')

mkdir _temp

# Split audio into slices
#for ((i=1;i<=${SLICES};i++)); do
#	ffmpeg -i ${VIDEO} -ss $(awk "BEGIN { print ${SLICE_LENGTH} * (${i}-1) }") -t ${SLICE_LENGTH} -sn -vn -acodec copy _temp/$(printf "%03d" "${i}").aac
#done
#ffmpeg -i ${VIDEO} -ss $(awk "BEGIN { print ${SLICE_LENGTH} * ${SLICES} }") -sn -vn -acodec copy _temp/$(printf "%03d" "$(awk "BEGIN { print ${SLICES} + 1 }")").aac
ffmpeg -i ${VIDEO} -f segment -segment_time ${SLICE_LENGTH} -sn -vn -acodec copy _temp/%03d.aac

# Separate music and vocals with spleeter
PARAMETER=""
for ((i=0;i<=${SLICES};i++)); do
	PARAMETER="${PARAMETER} $(echo -n "_temp/$(printf "%03d" "${i}").aac")"
done
spleeter separate -i ${PARAMETER} -p spleeter:2stems -m -o _temp

# Join audio files
PARAMETER=""
for ((i=0;i<=${SLICES};i++)); do
	PARAMETER="${PARAMETER} $(echo -n "-i _temp/$(printf "%03d" "${i}")/vocals.wav")"
done
ffmpeg ${PARAMETER} -filter_complex concat=n=$(awk "BEGIN { print ${SLICES} + 1 }"):v=0:a=1 -f mp4 -vn _temp/_vocals.mp4

# Add audio file to video
ffmpeg -i ${VIDEO} -i _temp/_vocals.mp4 -map 0:v -map 0:a -map 1:a -codec copy -shortest -bsf:a aac_adtstoasc -movflags faststart "$(basename ${VIDEO} .hls).mp4"

# Remove temporary files
rm -rf _temp


