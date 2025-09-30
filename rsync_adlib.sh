#!/bin/sh

NAME="rsync_adlib"
VERSION="1.12"

RSYNC="/opt/bin/rsync"
USER="$(whoami)"

IFS=$'\n'

EXCLUDE="
- .DocumentRevisions-V100
- .Spotlight-V100
- .TemporaryItems
- .Trashes
- .VolumeIcon.icns
- .fseventsd
- .ssh
- /.cache/fontconfig/
- /Library/Saved Application State
- /Library/Preferences/com.apple.systempreferences.plist
- /Library/Preferences/com.apple.screensaver.plist
- /Library/Preferences/MobileMeAccounts.plist
- /Library/Caches/storeaccountd/
- /Library/Containers/com.apple.CloudPhotosConfiguration/
- /Library/Containers/com.apple.cloudphotosd/
- /Library/SyncedPreferences/
- /Library/IdentityServices/
- /Library/Containers/com.apple.soagent/
- /Library/Containers/com.apple.photolibraryd/
- /Library/Containers/com.apple.lateragent/
- /Library/Containers/com.apple.SocialPushAgent/
- /Library/Caches/com.apple.commerce/
- /Library/Caches/com.apple.gamed/
- /Library/Caches/GameKit/
- /Library/Caches/com.apple.AOSPushRelay/
- /Library/Preferences/com.apple.metadata.SpotlightNetHelper.plist
- /Library/Preferences/com.apple.ids.*
- /Library/Preferences/callservicesd.plist
- /Library/Preferences/com.apple.CoreGraphics.plist
- /Library/Preferences/com.apple.FaceTime.plist
- /Library/Preferences/com.apple.appstore.plist
- /Library/Preferences/com.apple.commerce.plist
- /Library/Preferences/com.apple.driver.*
- /Library/Preferences/com.apple.facetime.*
- /Library/Preferences/com.apple.gamed.plist
- /Library/Application Support/com.apple.spotlight*
- /Library/Application Support/CrashReporter/
- /Library/Application Support/com.apple.TCC/
- /Library/Caches/TemporaryItems/
- /Library/Caches/com.apple.QuickLookDaemon/
- /Library/Caches/com.apple.Spotlight/
- /Library/Caches/com.apple.finder/
- /Library/Caches/com.apple.imfoundation.IMRemoteURLConnectionAgent/
- /Library/Caches/com.apple.safaridavclient/
- /Library/Caches/com.apple.syncdefaultsd/
- /Library/Caches/org.tynsoe.geektool3/
- /Library/Keychains/
- /Library/Logs/
- /Library/Preferences/ByHost/
- /Library/Application Support/Dock/desktoppicture.db
- /Library/Preferences/com.apple.desktop.plist
- /Library/Preferences/com.apple.recentitems.plist
- /Library/Preferences/com.apple.loginitems.plist
- /Library/Preferences/com.apple.notificationcenterui.plist
- /Library/Preferences/com.apple.security.KCN.plist
- /Library/Preferences/com.apple.security.plist
- /Preferences/com.apple.sidebarlists.plist
- /Library/Preferences/com.apple.spaces.plist
- /Library/Preferences/com.apple.universalaccess.plist
- /Library/Preferences/com.apple.xpc.activity2.plist
- com.crystalidea.MacsFanControl.plist
- com.apple.ColorSyncCalibrator.plist
- com.apple.ColorSyncUtility.LSSharedFileList.plist
- com.apple.ColorSyncUtility.plist
- ColorPickers
- Colors
- ColorSync
- SMARTReporter
- /Library/Preferences/com.corecode.SMARTReporter.plist
- /Documents/EyeTV Archive
- /Library/Accounts
- /Library/Application Support/iCloud
- Application Support/SyncServices
- /Library/Preferences/com.elgato.eyetv.devices.plist
- /Library/Preferences/com.elgato.eyetv.plist
- /Library/Preferences/com.apple.cloudpaird.plist
- /Library/Preferences/com.apple.icloud.*
- /Library/Preferences/com.apple.security.cloudkeychainproxy3.*
- /Library/Preferences/com.apple.dock.plist
- /Library/Preferences/com.apple.ids.*
- /Library/Application Support/iCloud
- /Library/Caches/CloudKit
- /Library/Caches/com.apple.iCloudHelper
- /Caches/CloudKit
- /Containers/com.apple.internetaccounts
- /SyncedPreferences
- /Library/Application Support/Ableton
- /Library/Preferences/ThnkDev.QuickRes.plist
- /Library/Caches/ThnkDev.QuickRes
- /Library/Preferences/com.adobe.*
- /Library/Preferences/com.Adobe.*
- /Library/Cookies/com.adobe.*
- /Library/WebKit/com.adobe.*
- /Library/Preferences/Adobe*
- /Library/Application Support/Adobe
- /Library/Caches/com.adobe.*
- /Library/Caches/Adobe*
- /Documents/Adobe
- /Pictures/Lightroom
- /Library/Application Support/Helicon
- /Library/Application Support/HeliconFocus
- /Library/Preferences/com.helicon.*
- /Library/Preferences/com.heliconsoft.*
- /Library/Preferences/com.HeliconSoft.*
- /Library/Preferences/com.canon.*
- /Library/Preferences/jp.co.canon.*
- /Library/Application Support/Canon*
"



function help() {
	echo "${0} does rsync data from this host to another host."
	echo
	echo "Usage: ${0}"
	echo
	echo "send bug-reports to <kristian.peters@korseby.net>"
}



function process_put() {
	if [[ "$USER" == "kristian" ]] || [[ "$USER" == "root" ]] ; then
		echo "${EXCLUDE}" > /tmp/${NAME}_exclude.list
		${RSYNC} --exclude-from=/tmp/${NAME}_exclude.list --archive --xattrs --hard-links --acls --delete --delete-after  --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Users/kristian/ --rsh="ssh -i ~/.ssh/id_rsa -p 22" "kristian@10.12.6.98:/Users/kristian/"
	fi
	
	if [[ "$USER" == "novisad" ]] || [[ "$USER" == "root" ]] ; then
		echo "${EXCLUDE}" > /tmp/${NAME}_exclude.list
		${RSYNC} --exclude-from=/tmp/${NAME}_exclude.list --archive --xattrs --hard-links --acls --delete --delete-after  --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Users/novisad/ --rsh="ssh -i ~/.ssh/id_rsa -p 22" "novisad@10.12.6.98:/Users/novisad/"
		ssh -p 22 novisad@10.12.6.98 /Users/novisad/Music/fix_traktor.sh	
	fi
	
	if [[ "$USER" == "root" ]] ; then
		${RSYNC} --archive --hard-links --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Users/Shared/Collection/ --rsh="ssh -i ~/.ssh/id_rsa -p 22" "admin@10.12.6.98:/Users/Shared/Collection/"
		${RSYNC} --archive --hard-links --delete --delete-after --ignore-errors --force-delete --verbose --out-format="%o: %f (%b/%l)" /Applications/Zusatzprogramme/ --rsh="ssh -i ~/.ssh/id_rsa -p 22" "admin@10.12.6.98:/Applications/Zusatzprogramme/"
	fi
}



if [ "${1}" == "--help" ] || [ "${1}" == "-help" ] || [ "${1}" == "-h" ] || [ "${1}" == "-?" ] ; then
	help
else
	process_put
	
	rm -f /tmp/${NAME}_exclude.list
fi


