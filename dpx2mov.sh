#!/usr/bin/env bash
# version: 1.0
#
# (c) Kristian Peters 2025
# released under the terms of GPL
#
# changes: 1.0 - first release
#
# contact: <kristian@korseby.net>

IFS=$'\n'
RANDOM_ID="$(xxd -u -l 4 -p /dev/urandom)"
FORMAT="prores_ks"
FORMAT_VERSION="3"			#4444
VENDOR="ap10"
SND_PCM="pcm_s24le"
PIX_FMT="yuv422p10le"		#yuva444p10le
COLOR_PRIMARIES="bt2020"
COLOR_TRC="bt2020-10"



function help() {
	echo "${0} converts a directory with DPX files and beginning with A_ to a single MOV file."
	echo
	echo "Usage: ${0} A_*"
	echo
	echo "send bug-reports to <kristian@korseby.net>"
}



function process() {
	ffmpeg -start_number 0001 -f image2 -r 50 -i "${1}/${1}_%08d.DPX" -i "${1}/${1}_00000001.WAV" -i "${1}/${1}_00000002.WAV" -i "${1}/${1}_00000003.WAV" -i "${1}/${1}_00000004.WAV" -filter_complex "[1:a][2:a][3:a][4:a]amerge=inputs=4[aout]" -map 0:v -map "[aout]" -c:a ${SND_PCM} -c:v ${FORMAT} -profile:v ${FORMAT_VERSION} -vendor ${VENDOR} -pix_fmt ${PIX_FMT} -color_primaries ${COLOR_PRIMARIES} -color_trc ${COLOR_TRC} -movflags use_metadata_tags "$i.MOV"
}



if [ "${1}" == "-h" ] || [ "${1}" == "--help" ] || [ "${1}" == "" ]; then
	help
else
	if [[ ${#} -lt 1 ]]; then
		echo "Error. No directories beginning with A_ given as arguments."
		exit 2
	fi
	for ((j=1; j<=${#}; j++)); do
		if [[ ! -d ${1} ]]; then
			echo "Error. ${1} is not a directory."
			exit 3
		fi
	done
	for i in "$@"; do
		process "${i}"
	done
fi



##ffmpeg -start_number 0001 -f image2 -r 50 -i A_0007C018X241230_102935EJ_CANON_%08d.dpx -i A_0007C018X241230_102935EJ_CANON_00000001.WAV -i A_0007C018X241230_102935EJ_CANON_00000002.WAV -i A_0007C018X241230_102935EJ_CANON_00000003.WAV -i A_0007C018X241230_102935EJ_CANON_00000004.WAV -filter_complex "[1:a][2:a][3:a][4:a]amerge=inputs=4[aout]" -map 0:v -map "[aout]" -c:a pcm_s24le -c:v prores_ks -profile:v 3 -vendor ap10 -pix_fmt yuv422p10le -color_primaries bt2020 -color_trc bt2020-10 -movflags use_metadata_tags _output3.mov

##ffmpeg -start_number 0001 -f image2 -r 50 -i A_0007C018X241230_102935EJ_CANON_%08d.dpx -i A_0007C018X241230_102935EJ_CANON_00000001.WAV -i A_0007C018X241230_102935EJ_CANON_00000002.WAV -i A_0007C018X241230_102935EJ_CANON_00000003.WAV -i A_0007C018X241230_102935EJ_CANON_00000004.WAV -filter_complex "[1:a][2:a][3:a][4:a]amerge=inputs=4[aout]" -map 0:v -map "[aout]" -c:a pcm_s24le -c:v prores_ks -profile:v 4444 -pix_fmt yuva444p10le -color_primaries bt2020 -color_trc bt2020-10 -movflags use_metadata_tags _output.mov
