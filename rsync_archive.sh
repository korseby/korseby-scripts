#!/bin/sh

NAME="rsync_backup"
VERSION="1.6"

RSYNC="/opt/bin/rsync"

IFS=$'\n'



function help() {
	echo "${0} does rsync data from this host to another host."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function process() {
	ping -c 1 -W 1 10.12.6.98
	if [[ $? -eq 0 ]]; then
		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/archive/20* --rsh="ssh -p 22" "kristian@10.12.6.98:/Volumes/archive/"
		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/archive/Installation/ --rsh="ssh -p 22" "kristian@10.12.6.98:/Volumes/archive/Installation/"
		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/archive/___processing___/ --rsh="ssh -p 22" "kristian@10.12.6.98:/Volumes/archive/___processing___/"
		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/archive/___raw___/ --rsh="ssh -p 22" "kristian@10.12.6.98:/Volumes/archive/___raw___/"
		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/archive/00* --rsh="ssh -p 22" "kristian@10.12.6.98:/Volumes/archive/"
	fi
	
	#ping -c 1 -W 1 tm-backup
	#if [[ $? -eq 0 ]]; then
	#	if [[ $(mount | grep tm-backup) == "" ]] || [[ $(mount | grep /Volumes/Time\ Machine\ Backups) == "" ]]; then
	#		echo "Trying to open Time Machine Backup manually..."
	#		sleep 5
	#		open smb://tm-backup@tm-backup.localnet/tm-backup
	#		sleep 20
	#		hdiutil attach /Volumes/tm-backup/$(uname -n | sed -e 's/\..*//').backupbundle
	#		sleep 10
	#	fi
	#	
	#	if [[ $(mount | grep tm-backup) != "" ]] && [[ $(mount | grep /Volumes/Time\ Machine\ Backups) != "" ]]; then
	#		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/20* /Volumes/Time\ Machine\ Backups/
	#		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/Installation/ /Volumes/Time\ Machine\ Backups/Installation/
	#		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___processing___/ /Volumes/Time\ Machine\ Backups/___processing___/
	#		${RSYNC} --archive --xattrs --hard-links --acls --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___raw___/ /Volumes/Time\ Machine\ Backups/___raw___/
	#	fi
	#fi
}



if [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	process
fi


