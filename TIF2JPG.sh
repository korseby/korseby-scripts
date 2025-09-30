#!/usr/bin/env bash

IFS=$'\n'
QUALITY="100"
CONVERT="$(which convert)"
EXIFTOOL="$(which exiftool)"
PARALLEL="$(getconf _NPROCESSORS_ONLN)"

# Check for ImageMagick and Exiftool
if [[ ${CONVERT} == "" ]] || [[ ${EXIFTOOL} == "" ]]; then
	echo "Error! No ImageMagick convert or exiftool detected."
	exit 2
fi

# Process
process() {
	i="${1}"
	INPUT="${i}"
	OUTPUT="$(echo ${i} | perl -pe 's/\.TIF.*/\.JPG/')"
	
	convert -define preserve-timestamp=true -format jpg -quality 100 "$i" "$(echo $i | perl -pe 's/\.TIF*/\.JPG/')"
	exiftool -overwrite_original_in_place -tagsFromFile "$i" "$(echo $i | perl -pe 's/\.TIF*/\.JPG/')"
}

# MAIN
echo "Generating thumbnails..."
for j in $(find . -name '*.TIF*'); do
	((count=count%PARALLEL)); ((count++==0)) && wait
	process "$j" &
done
