#!/bin/bash

ios_platform_path=`xcrun --sdk iphoneos --show-sdk-platform-path`
ios_version=`xcrun --sdk iphoneos --show-sdk-platform-version`
ios_version="8.4"

dev_image=`find "$ios_platform_path/DeviceSupport" -regex ".*$ios_version.*/DeveloperDiskImage.dmg"`
dev_image_mountpoint="/Volumes/DeveloperDiskImage"

script_path=`dirname $0`
framework_path="$script_path/layout/Library/PrivateFrameworks/"

if [ ! -f "$dev_image" ]
then
	echo "[ERROR]	DeveloperDiskImage not found!!! ($ios_platform_path/DeviceSupport/$ios_version.*)"
	exit 1
fi
echo "Developer Image found: $dev_image"


hdiutil attach -quiet -nobrowse "$dev_image"
if [ $? -ne 0 -o ! -d "$dev_image_mountpoint" ]
then
	echo "[ERROR]	Unable to mount DeveloperDiskImage!!!"
	exit 1
fi	

cp -ir "$dev_image_mountpoint/Library/PrivateFrameworks/UIAutomation.framework" "$framework_path"


hdiutil detach -quiet "$dev_image_mountpoint"
if [ $? -ne 0 ]
then
	echo "[WARNING]	Unable to unmount DeveloperDiskImage!!!"
fi	

#Updating the bundled UIAutomation-framework requires some path changes
#to avoid conflicting paths with the original one.
`xcrun -find install_name_tool` -id "/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" "$framework_path/UIAutomation.framework/UIAutomation"

echo "UIAutomation.framework has been sucessfully updated!"


