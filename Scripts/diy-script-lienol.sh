#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Actions

Diy_Core() {
Author=Les.W
Default_Device=d-team_newifi-d2
}

Diy-Part1() {
[ -e feeds.conf.default ] && sed -i "s/#src-git helloworld/#src-git helloworld/g" feeds.conf.default
[ ! -d package/lean ] && mkdir -p package/lean

#Replace_File mac80211.sh package/kernel/mac80211/files/lib/wifi
Replace_File uhttpd.config package/network/services/uhttpd/files
Replace_File system package/base-files/files/etc/config
#Replace_File AutoUpdate.sh package/base-files/files/bin
Replace_File banner package/base-files/files/etc

ExtraPackages svn network/services dnsmasq https://github.com/openwrt/openwrt/trunk/package/network/services
ExtraPackages svn network/services dropbear https://github.com/openwrt/openwrt/trunk/package/network/services
ExtraPackages svn network/services ppp https://github.com/openwrt/openwrt/trunk/package/network/services
ExtraPackages svn network/services hostapd https://github.com/openwrt/openwrt/trunk/package/network/services
ExtraPackages svn kernel mac80211 https://github.com/openwrt/openwrt/trunk/package/kernel
# ExtraPackages svn kernel mt76 https://github.com/openwrt/openwrt/trunk/package/kernel

#ExtraPackages git lean luci-app-autoupdate https://github.com/Hyy2001X main
ExtraPackages git lean luci-theme-argon https://github.com/jerrykuku 18.06
ExtraPackages git other luci-app-argon-config https://github.com/jerrykuku master
ExtraPackages git other luci-app-adguardhome https://github.com/Hyy2001X master
ExtraPackages svn other luci-app-smartdns https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t
ExtraPackages svn other smartdns https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t
ExtraPackages git other OpenClash https://github.com/vernesong master
ExtraPackages git other luci-app-serverchan https://github.com/tty228 master
ExtraPackages svn other luci-app-socat https://github.com/project-openwrt/openwrt/trunk/package/lienol
# [UPX 压缩] ExtraPackages git other openwrt-upx https://github.com/Hyy2001X master
# [应用过滤] ExtraPackages git OAF openwrt-OpenAppFilter https://github.com/Lienol master
# [AdGuardHome 核心] ExtraPackages svn other AdGuardHome https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t
}

Diy-Part2() {
GET_TARGET_INFO
echo "Author: $Author"
echo '修改默认主题'
sed -i 's/config internal themes/config internal themes\n    option Argon  \"\/luci-static\/argon\"/g' $GITHUB_WORKSPACE/openwrt/feeds/luci/modules/luci-base/root/etc/config/luci
echo '去除默认bootstrap主题'
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' $GITHUB_WORKSPACE/openwrt/feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#Replace_File mwan3 package/feeds/packages/mwan3/files/etc/config
# ExtraPackages svn feeds/packages mwan3 https://github.com/openwrt/packages/trunk/net
echo "Author: $Author"
echo "Openwrt Version: $Openwrt_Version"
# echo "AutoUpdate Version: $AutoUpdate_Version"
echo "Router: $TARGET_PROFILE"
sed -i "s/$Lede_Version/& Compiled by $Author [$Display_Date]/" $Default_File
echo "$Openwrt_Version" > package/base-files/files/etc/openwrt_info
sed -i "s/Openwrt/& $Openwrt_Version/" package/base-files/files/etc/banner
}

Diy-Part3() {
GET_TARGET_INFO
Default_Firmware=openwrt-$TARGET_BOARD-$TARGET_SUBTARGET-$TARGET_PROFILE-squashfs-sysupgrade.bin
AutoBuild_Firmware=AutoBuild-$TARGET_PROFILE-Lede-${Openwrt_Version}.bin
AutoBuild_Detail=AutoBuild-$TARGET_PROFILE-Lede-${Openwrt_Version}.detail
mkdir -p bin/Firmware
echo "Firmware: $AutoBuild_Firmware"
mv bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET/$Default_Firmware bin/Firmware/$AutoBuild_Firmware
echo "[$(date "+%H:%M:%S")] Calculating MD5 and SHA256 ..."
Firmware_MD5=$(md5sum bin/Firmware/$AutoBuild_Firmware | cut -d ' ' -f1)
Firmware_SHA256=$(sha256sum bin/Firmware/$AutoBuild_Firmware | cut -d ' ' -f1)
echo -e "MD5: $Firmware_MD5\nSHA256: $Firmware_SHA256"
touch bin/Firmware/$AutoBuild_Detail
echo -e "\nMD5:$Firmware_MD5\nSHA256:$Firmware_SHA256" >> bin/Firmware/$AutoBuild_Detail
}

GET_TARGET_INFO() {
Diy_Core
[ -e $GITHUB_WORKSPACE/Openwrt.info ] && . $GITHUB_WORKSPACE/Openwrt.info
#AutoUpdate_Version=$(awk 'NR==6' package/base-files/files/bin/AutoUpdate.sh | awk -F '[="]+' '/Version/{print $2}')
Default_File="package/default-settings/files/zzz-default-settings"
Lede_Version=$(egrep -o "[0-9]+\.[0-9]+\-SNAPSHOT+" $Default_File)
Openwrt_Version="$Lede_Version-$Compile_Date"
TARGET_PROFILE=$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')
[ -z "$TARGET_PROFILE" ] && TARGET_PROFILE="$Default_Device"
TARGET_BOARD=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)
TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)
}

ExtraPackages() {
PKG_PROTO=$1
PKG_DIR=$2
PKG_NAME=$3
REPO_URL=$4
REPO_BRANCH=$5

[ -d package/$PKG_DIR ] && mkdir -p package/$PKG_DIR
[ -d package/$PKG_DIR/$PKG_NAME ] && rm -rf package/$PKG_DIR/$PKG_NAME
[ -d $PKG_NAME ] && rm -rf $PKG_NAME
Retry_Times=3
while [ ! -e $PKG_NAME/Makefile ]
do
	echo "[$(date "+%H:%M:%S")] Checking out package [$PKG_NAME] ..."
	case $PKG_PROTO in
	git)
		git clone -b $REPO_BRANCH $REPO_URL/$PKG_NAME $PKG_NAME > /dev/null 2>&1
	;;
	svn)
		svn checkout $REPO_URL/$PKG_NAME $PKG_NAME > /dev/null 2>&1
	esac
	if [ -e $PKG_NAME/Makefile ] || [ -e $PKG_NAME/README* ];then
		echo "[$(date "+%H:%M:%S")] Package [$PKG_NAME] is detected!"
		mv $PKG_NAME package/$PKG_DIR
		break
	else
		[ $Retry_Times -lt 1 ] && echo "[$(date "+%H:%M:%S")] Skip check out package [$PKG_NAME] ..." && break
		echo "[$(date "+%H:%M:%S")] [Error] [$Retry_Times] Checkout failed,retry in 3s ..."
		Retry_Times=$(($Retry_Times - 1))
		rm -rf $PKG_NAME > /dev/null 2>&1
		sleep 3
	fi
done
}

Replace_File() {
FILE_NAME=$1
PATCH_DIR=$GITHUB_WORKSPACE/openwrt/$2
FILE_RENAME=$3

[ ! -d $PATCH_DIR ] && mkdir -p $PATCH_DIR
if [ -f $GITHUB_WORKSPACE/Customize/$FILE_NAME ];then
	if [ -e $GITHUB_WORKSPACE/Customize/$FILE_NAME ];then
		echo "[$(date "+%H:%M:%S")] Customize File [$FILE_NAME] is detected!"
		if [ -z $FILE_RENAME ];then
			[ -e $PATCH_DIR/$FILE_NAME ] && rm -f $PATCH_DIR/$FILE_NAME
			mv -f $GITHUB_WORKSPACE/Customize/$FILE_NAME $PATCH_DIR/$1
		else
			[ -e $PATCH_DIR/$FILE_NAME ] && rm -f $PATCH_DIR/$3
			mv -f $GITHUB_WORKSPACE/Customize/$FILE_NAME $PATCH_DIR/$3
		fi
	else
		echo "[$(date "+%H:%M:%S")] Customize File [$FILE_NAME] is not detected,skip move ..."
	fi
else
	if [ -d $GITHUB_WORKSPACE/Customize/$FILE_NAME ];then
		echo "[$(date "+%H:%M:%S")] Customize Folder [$FILE_NAME] is detected !"
		mv -f $GITHUB_WORKSPACE/Customize/$FILE_NAME $PATCH_DIR
	else
		echo "[$(date "+%H:%M:%S")] Customize Folder [$FILE_NAME] is not detected,skip move ..."
	fi
fi
}
