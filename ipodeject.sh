#!/bin/sh

function failure () {
	errorcode=$?
	if [ $errorcode != 1 ] ; then
		echo "The iPod could not be ejected. (script exited with error code $errorcode)"
		exit $errorcode
	fi
}


umount /mnt/ipod || failure $?
umount /mnt/backpod || failure $?

rmmod sbp2 || failure $?
rmmod ohci1394 || failure $?
rmmod ieee1394 || failure $?
rmmod hfsplus || failure $?
rmmod hfs || failure $?
