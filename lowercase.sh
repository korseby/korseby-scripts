#! /bin/sh
# tolower.sh: convert file names to lower case
# in the current working directory
# Choose either all the files in a directory or
# a command-line list

if [ "$#" -gt 0 ]; then
	filelist="$@"		# just the files on command line
else
	filelist=`ls`		# all files
fi

for file in $filelist; do
	# Use the grep command to determine if the file
	# has an upper case letter
	# Determine the destination of the mv command by
	# down shifting all the
	# letters in the file name. Command substituting an
	# echo of the file name to the translate filter, tr,
	# performs the downshift
	if echo "$file"|grep [A-Z] > /dev/null; then
		mv "$file" `echo "$file"|tr "[A-Z]" "[a-z]"`
	fi
done
