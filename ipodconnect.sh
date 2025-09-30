#!/bin/sh

modprobe hfs
modprobe hfsplus
modprobe ieee1394
modprobe ohci1394
modprobe sbp2
rescan-scsi-bus.sh

