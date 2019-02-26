#!/bin/sh

NAME="rsync_installation_dir"
VERSION="1.3"

RSYNC="/opt/bin/rsync"

IFS="
"



function help() {
	echo "${0} does rsync data from this host to another host."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function process() {
	ping -c 1 -W 1 novisad
	if [[ $? -eq 0 ]]; then
		${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/20* --rsh="ssh -p 22" "kristian@novisad:/Volumes/archive/"
		${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/Installation/ --rsh="ssh -p 22" "kristian@novisad:/Volumes/archive/Installation/"
		${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___processing___/ --rsh="ssh -p 22" "kristian@novisad:/Volumes/archive/___processing___/"
		${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___raw___/ --rsh="ssh -p 22" "kristian@novisad:/Volumes/archive/___raw___/"
	fi
	
	ping -c 1 -W 1 tm-backup
	if [[ $? -eq 0 ]]; then
		if [[ $(mount | grep tm-backup.localnet) == "" ]] || [[ $(mount | grep /Volumes/Time\ Machine\ Backups) == "" ]]; then
			echo "Trying to open Time Machine Backup manually..."
			sleep 5
			open afp://tm-backup@tm-backup.localnet/tm-backup
			sleep 20
			hdiutil attach /Volumes/tm-backup/$(uname -n | sed -e 's/\..*//').sparsebundle
			sleep 10
		fi
		
		if [[ $(mount | grep tm-backup.localnet) != "" ]] && [[ $(mount | grep /Volumes/Time\ Machine\ Backups) != "" ]]; then
			${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/20* /Volumes/Time\ Machine\ Backups/
			${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/Installation/ /Volumes/Time\ Machine\ Backups/Installation/
			${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___processing___/ /Volumes/Time\ Machine\ Backups/___processing___/
			${RSYNC} --archive --xattrs --acls --delete --verbose --out-format="%o: %f (%b/%l)" /Volumes/backup/___raw___/ /Volumes/Time\ Machine\ Backups/___raw___/
		fi
	fi
}



if [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	process
fi
