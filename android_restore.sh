#!/usr/bin/env bash

basepath="/home/grapz/Backup/Android/"

## List backups and make user select one
for dir in $basepath* ; do
	if [ -d "$dir" ] ; then
		echo $(basename $dir)
	fi
done

echo "Type the backup you would like to restore, followed by [ENTER]:"
read resp

if [ -d "$basepath$resp" ] ; then
	adb remount

	## Reinstall all apps
	for file in $basepath$resp/app/* ; do
		adb install $file
	done

	for filepriv in $basepath$resp/app-private/* ; do
		adb install $filepriv
	done

	## Remove data on device, restore backup and set permissions
	for datadir in $basepath$resp/data/* ; do
		tmp=$(basename $datadir)
		adb shell rm -r /data/data/$tmp
		adb push $datadir /data/data/$tmp/
		adb shell chmod 777 /data/data/$tmp
		adb shell chmod 777 /data/data/$tmp/*/*
	done

	## Fix permissions
	adb shell fix_permissions

	## Reboot phone
	adb shell reboot
else
	echo "The backup $resp does not exist. Exiting..."
fi
