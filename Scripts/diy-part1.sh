#!/bin/bash
#=============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=============================================================

# fw876/helloworld
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Lienol/openwrt-package
#sed -i '$a src-git lienol https://github.com/Lancenas/lienol-openwrt-package.git' feeds.conf.default
sed -i '$a src-git luci-lienol https://github.com/Lienol/openwrt-luci.git;17.01' feeds.conf.default
sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package.git;main' feeds.conf.default
sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main' feeds.conf.default
sed -i '$a src-git freifunk https://github.com/freifunk/openwrt-packages.git;openwrt-19.07' feeds.conf.default
#sed -i '$a src-git luci-app-adguardhome https://github.com/rufengsuixing/luci-app-adguardhome' feeds.conf.default
