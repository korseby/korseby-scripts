#!/bin/sh

#MPLAYER_BINARY="/Applications/Zusatzprogramme/MPlayerX.app/Contents/Resources/binaries/x86_64/mplayer"
MPLAYER_BINARY="/Applications/Zusatzprogramme/MPlayerX.app/Contents/Resources/MPlayerX.mplayer.bundle/Contents/Resources/x86_64/mplayer"

for i in *.m4a; do
	#$MPLAYER_BINARY -ao pcm "$i" -ao pcm:waveheader:file="$(echo $i | sed -e "s/\.m4a//").wav"
	#$MPLAYER_BINARY -ao pcm "$i" -ao pcm:file="$(echo $i | sed -e "s/\.m4a//").wav"
	$MPLAYER_BINARY -benchmark -vc null -vo null "$i" -ao pcm:fast:waveheader:file="$(echo $i | sed -e "s/\.m4a//").wav"
done

