#!/bin/sh
HOME="${HOME}"
EXIFTOOL="$(which exiftool)"

for i in ${*}; do
	FILENAME="$i"

	cp -f ${FILENAME} ${FILENAME}_original

	exiftool -P \
		-ALL= \
		-TagsFromFile ${FILENAME}_original \
		-IFD0:ALL \
		-ExifIFD:CreateDate \
		-ExifIFD:ExposureTime \
		-ExifIFD:FNumber \
		-ExifIFD:ISO \
		-ExifIFD:ExifVersion \
		-ExifIFD:DateTimeOriginal \
		-ExifIFD:ComponentsConfiguration \
		-ExifIFD:ShutterSpeedValue \
		-ExifIFD:ApertureValue \
		-ExifIFD:ExposureCompensation \
		-ExifIFD:Flash \
		-ExifIFD:FocalLength \
		-ExifIFD:ColorSpace \
		-ExifIFD:ExposureMode \
		-ExifIFD:WhiteBalance \
		-Exif:GPSLatitudeRef \
		-Exif:GPSLatitude \
		-Exif:GPSLongitudeRef \
		-Exif:GPSLongitude \
		-Exif:GPSAltitudeRef \
		-Exif:GPSAltitude \
		-Exif:GPSImgDirectionRef \
		-Exif:GPSImgDirection \
		-Exif:GPSTimeStamp \
		-Exif:GPSMapDatum \
		-Exif:GPSDateStamp \
		-Exif:GPSDifferential \
		-Exif:GPSHPositioningError \
		-Canon:MacroMode \
		-Canon:Self-timer \
		-Canon:Quality \
		-Canon:CanonFlashMode \
		-Canon:ContinuousDrive \
		-Canon:FocusMode \
		-Canon:EasyMode \
		-Canon:Contrast \
		-Canon:Saturation \
		-Canon:Sharpness \
		-Canon:MeteringMode \
		-Canon:FocusRange \
		-Canon:CanonExposureMode \
		-Canon:LensType \
		-Canon:LongFocal \
		-Canon:ShortFocal \
		-Canon:FocalUnits \
		-Canon:MaxAperture \
		-Canon:MinAperture \
		-Canon:ColorTone \
		-Canon:FocalType \
		-Canon:FocalLength \
		-Canon:FocalPlaneXSize \
		-Canon:FocalPlaneYSize \
		-Canon:MeasuredEV \
		-Canon:TargetAperture \
		-Canon:TargetExposureTime \
		-Canon:ExposureCompensation \
		-Canon:WhiteBalance \
		-Canon:SlowShutter \
		-Canon:FlashGuideNumber \
		-Canon:FlashExposureCompensation \
		-Canon:CanonImageType \
		-Canon:OwnerName \
		-Canon:CanonModelID \
		-Canon:NumAFPoints \
		-Canon:CanonImageWidth  \
		-Canon:CanonImageHeight \
		-Canon:AFPointsUsed \
		-Canon:FileNumber \
		-Canon:NoiseReduction \
		-Canon:LensType \
		-Canon:WhiteBalance \
		-Canon:ColorTemperature \
		-Composite:ALL \
		-Artist="Kristian Peters" \
		-Owner="Kristian Peters" \
		-OwnerName="Kristian Peters" \
		-CreatorTool= \
		-Software= \
		-Copyright="The author of this image is Kristian Peters. He owns the original copyright. This work is licensed under Creative Commons 3.0 cc-by-sa-nc license." \
		${FILENAME}

	mv ${FILENAME}_original ${HOME}/.Trash/
done

