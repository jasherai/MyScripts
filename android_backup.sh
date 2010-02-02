#!/usr/bin/env bash

##
## $packagefile must be in $basepath directory
##

basepath="/home/grapz/Backup/Android/"
backuppath=`eval date +%Y%m%d_%H%M`
packagefile="packages.txt"

## Create folders
cd $basepath
mkdir -p $backuppath/data

adb remount

## Pull all non-system apps
adb pull /system/sd/app $basepath$backuppath/app
adb pull /system/sd/app-private $basepath$backuppath/app-private

## Pull data for each app in $packagefile
cat $basepath$packagefile | while read LINE ; do
	adb pull /data/data/$LINE/ $basepath$backuppath/data/$LINE
done
