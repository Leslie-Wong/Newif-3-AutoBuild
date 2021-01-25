#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild DiyScript

Diy_Core() {
	Author=Hyy2001
	Default_Device=d-team_newifi-d2

	INCLUDE_AutoUpdate=true
	INCLUDE_AutoBuild_Tools=true
	INCLUDE_SSR_Plus=true
	INCLUDE_Passwall=false
	INCLUDE_Latest_Xray=true
	INCLUDE_mt7621_OC1000MHz=true
	INCLUDE_Enable_FirewallPort_53=true
}

Diy-Part1() {
	Diy_Part1_Base
	
	Replace_File Customize/mac80211.sh package/kernel/mac80211/files/lib/wifi
	Replace_File Customize/system package/base-files/files/etc/config
	Replace_File Customize/banner package/base-files/files/etc

	# ExtraPackages svn network/services dnsmasq https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services dropbear https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services ppp https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn network/services hostapd https://github.com/openwrt/openwrt/trunk/package/network/services
	# ExtraPackages svn kernel mt76 https://github.com/openwrt/openwrt/trunk/package/kernel

	ExtraPackages git lean helloworld https://github.com/fw876 master
	ExtraPackages git lean luci-theme-argon https://github.com/jerrykuku 18.06
	ExtraPackages git other luci-app-argon-config https://github.com/jerrykuku master
	ExtraPackages git other luci-app-adguardhome https://github.com/Hyy2001X master
	ExtraPackages svn other luci-app-smartdns https://github.com/kenzok8/openwrt-packages/trunk
	ExtraPackages svn other smartdns https://github.com/kenzok8/openwrt-packages/trunk
	ExtraPackages git other OpenClash https://github.com/vernesong master
	ExtraPackages git other luci-app-serverchan https://github.com/tty228 master
	ExtraPackages svn other luci-app-socat https://github.com/Lienol/openwrt-package/trunk
}

Diy-Part2() {
	Diy_Part2_Base
	Replace_File Customize/mwan3.config package/feeds/packages/mwan3/files/etc/config mwan3
	# ExtraPackages svn feeds/packages mwan3 https://github.com/openwrt/packages/trunk/net
}

Diy-Part3() {
	Diy_Part3_Base
}
