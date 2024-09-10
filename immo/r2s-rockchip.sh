#!/bin/bash

## 移除 SNAPSHOT 标签
sed -i 's,SNAPSHOT,,g' include/version.mk
# sed -i 's,snapshots,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
# sed -i 's,snapshots,,g' package/base-files/image-config.in

## 修改openwrt登陆地址,把下面的192.168.11.1修改成你想要的就可以了
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate
#sed -i "s/192.168.1.1/${{ github.event.inputs.OP_IP }}/" package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

## r2s r2c风扇脚本
wget -P target/linux/rockchip/armv8/base-files/etc/init.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/init.d/fa-rk3328-pwmfan
wget -P target/linux/rockchip/armv8/base-files/usr/bin/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/usr/bin/start-rk3328-pwm-fan.sh

# rm -rf package/new
mkdir -p package/new

## set default-setting
# cp -rf $GITHUB_WORKSPACE/patches/default-settings package/new/default-settings

## clone kiddin9/openwrt-packages仓库
git clone https://github.com/kiddin9/openwrt-packages package/new/openwrt-packages

########## 添加包
# 定时重启
#cp -rf ../immortalwrt_luci/applications/luci-app-autoreboot ./feeds/luci/applications/luci-app-autoreboot
#ln -sf ../../../feeds/luci/applications/luci-app-autoreboot ./package/feeds/luci/luci-app-autoreboot

# 网络设置向导
git clone https://github.com/sirpdboy/luci-app-netwizard package/luci-app-netwizard

# autosamba自动共享
git clone https://github.com/sirpdboy/autosamba package/autosamba

## Add automount
mv package/new/openwrt-packages/automount package/new/automount

# Add luci-app-dockerman
rm -rf ../../customfeeds/luci/collections/luci-lib-docker
rm -rf ../../customfeeds/luci/applications/luci-app-docker
rm -rf ../../customfeeds/luci/applications/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-lib-docker

## Add luci-app-fileassistant luci-app-filetransfer
mv package/new/openwrt-packages/luci-app-fileassistant package/new/luci-app-fileassistant
mv package/new/openwrt-packages/luci-app-filetransfer package/new/luci-app-filetransfer
mv package/new/openwrt-packages/luci-lib-fs package/new/luci-lib-fs

## Add luci-app-upnp
rm -rf feeds/luci/applications/luci-app-upnp
rm -rf feeds/packages/net/miniupnpd
mv package/new/openwrt-packages/miniupnpd package/new/miniupnpd
mv package/new/openwrt-packages/luci-app-upnp package/new/luci-app-upnp

## Add luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata
mv package/new/openwrt-packages/v2ray-geodata package/new/v2ray-geodata
mv package/new/openwrt-packages/v2dat package/new/v2dat
mv package/new/openwrt-packages/mosdns package/new/mosdns
mv package/new/openwrt-packages/luci-app-mosdns package/new/luci-app-mosdns

rm -rf package/new/openwrt-packages

## openclash
bash $GITHUB_WORKSPACE/scripts/openclash.sh arm64

## ShellClash
bash $GITHUB_WORKSPACE/scripts/ShellClash.sh

## zsh
bash $GITHUB_WORKSPACE/scripts/zsh.sh

## turboacc
bash $GITHUB_WORKSPACE/scripts/turboacc_5_15.sh
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

ls -1 package/new/
