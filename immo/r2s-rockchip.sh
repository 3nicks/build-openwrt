#!/bin/bash

rm -rf target/linux package/kernel package/boot package/firmware package/network/utils/fullconenat-nft

mkdir new; cp -rf .git new/.git
cd new
git reset --hard origin/master

cp -rf --parents target/linux package/kernel package/boot package/network/utils/fullconenat-nft package/firmware include/kernel* config/Config-images.in config/Config-kernel.in include/image*.mk include/trusted-firmware-a.mk scripts/ubinize-image.sh package/utils/bcm27xx-utils package/devel/perf ../
cd ..

echo 'src-git xd https://github.com/shiyu1314/openwrt-packages' >>feeds.conf.default
git clone -b master --depth 1 --single-branch https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone -b v5-lua --depth 1 --single-branch https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone -b main --depth 1 --single-branch https://github.com/shiyu1314/homeproxy package/luci-app-homeproxy


./scripts/feeds update -a
rm -rf feeds/luci/applications/luci-app-homeproxy
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata

./scripts/feeds update -a
./scripts/feeds install -a

## rockchip机型,默认内核5.15，修改内核为6.1
# sed -i 's/PATCHVER:=5.15/PATCHVER:=6.1/g' target/linux/rockchip/Makefile

## 移除 SNAPSHOT 标签
sed -i 's,SNAPSHOT,,g' include/version.mk
# sed -i 's,snapshots,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
# sed -i 's,snapshots,,g' package/base-files/image-config.in

## 修改openwrt登陆地址,把下面的192.168.11.1修改成你想要的就可以了
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 定时重启
cp -rf ../immortalwrt_luci/applications/luci-app-autoreboot ./feeds/luci/applications/luci-app-autoreboot
ln -sf ../../../feeds/luci/applications/luci-app-autoreboot ./package/feeds/luci/luci-app-autoreboot

# 网络设置向导
git clone https://github.com/sirpdboy/luci-app-netwizard package/luci-app-netwizard

# autosamba自动共享
git clone https://github.com/sirpdboy/autosamba package/autosamba

# Add luci-app-dockerman
rm -rf ../../customfeeds/luci/collections/luci-lib-docker
rm -rf ../../customfeeds/luci/applications/luci-app-docker
rm -rf ../../customfeeds/luci/applications/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
git clone --depth=1 https://github.com/lisaac/luci-lib-docker

## r2s r2c风扇脚本
wget -P target/linux/rockchip/armv8/base-files/etc/init.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/init.d/fa-rk3328-pwmfan
wget -P target/linux/rockchip/armv8/base-files/usr/bin/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/usr/bin/start-rk3328-pwm-fan.sh

# rm -rf package/new
mkdir -p package/new

## set default-setting
# cp -rf $GITHUB_WORKSPACE/patches/default-settings package/new/default-settings

## 下载主题luci-theme-argon
# rm -rf feeds/luci/themes/luci-theme-argon
# rm -rf feeds/luci/applications/luci-app-argon-config
# git clone https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
# git clone https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
## 调整 LuCI 依赖，去除 luci-app-opkg，替换主题 bootstrap 为 argon
# sed -i '/+luci-light/d;s/+luci-app-opkg/+luci-light/' ./feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' ./feeds/luci/collections/luci-light/Makefile

## Add luci-app-wechatpush
# git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/new/luci-app-wechatpush

## Add luci-app-socat
# rm -rf feeds/packages/net/socat
# git clone https://github.com/immortalwrt/packages package/new/immortalwrt-packages
# mv package/new/immortalwrt-packages/net/socat package/new/socat
# rm -rf package/new/immortalwrt-packages
# rm -rf feeds/luci/applications/luci-app-socat
# git clone --depth 1 https://github.com/chenmozhijin/luci-app-socat package/new/chenmozhijin-socat
# mv -n package/new/chenmozhijin-socat/luci-app-socat package/new/
# rm -rf package/new/chenmozhijin-socat

## Add luci-app-ddns-go
# rm -rf feeds/luci/applications/luci-app-ddns-go
# rm -rf feeds/packages/net/ddns-go
# git clone --depth 1 https://github.com/sirpdboy/luci-app-ddns-go package/new/ddnsgo
# mv -n package/new/ddnsgo/*ddns-go package/new/
# rm -rf package/new/ddnsgo

## adguardhome
# git clone -b patch-1 https://github.com/kiddin9/openwrt-adguardhome package/new/openwrt-adguardhome
# mv package/new/openwrt-adguardhome/*adguardhome package/new/
# rm -rf package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml
# cp -rf $GITHUB_WORKSPACE/patches/AdGuardHome/AdGuardHome_template.yaml package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/AdGuardHome_template.yaml
# rm -rf package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/links.txt
# cp -rf $GITHUB_WORKSPACE/patches/AdGuardHome/links.txt package/new/luci-app-adguardhome/root/usr/share/AdGuardHome/links.txt
# rm -rf package/new/openwrt-adguardhome

## clone kiddin9/openwrt-packages仓库
git clone https://github.com/kiddin9/openwrt-packages package/new/openwrt-packages

########## 添加包
## Add luci-app-fileassistant luci-app-filetransfer
mv package/new/openwrt-packages/luci-app-fileassistant package/new/luci-app-fileassistant
mv package/new/openwrt-packages/luci-app-filetransfer package/new/luci-app-filetransfer
mv package/new/openwrt-packages/luci-lib-fs package/new/luci-lib-fs

## alist编译环境
# rm -rf feeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
# rm -rf feeds/luci/applications/luci-app-alist
# rm -rf feeds/packages/net/alist
# git clone https://github.com/sbwml/luci-app-alist package/new/sbwml-alist
# mv package/new/sbwml-alist/luci-app-alist package/new/luci-app-alist
# # mv package/new/sbwml-alist/alist package/new/alist
# rm -rf package/new/sbwml-alist


## Add luci-app-wolplus
# mv package/new/openwrt-packages/luci-app-wolplus package/new/luci-app-wolplus

## Add luci-app-onliner
# mv package/new/openwrt-packages/luci-app-onliner package/new/luci-app-onliner

## Add luci-app-poweroff
mv package/new/openwrt-packages/luci-app-poweroff package/new/luci-app-poweroff

## Add luci-app-irqbalance
# sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# mv package/new/openwrt-packages/luci-app-irqbalance package/new/luci-app-irqbalance

## Add automount
mv package/new/openwrt-packages/automount package/new/automount
mv package/new/openwrt-packages/ntfs3-mount package/new/ntfs3-mount

## Add luci-app-smartdns
# rm -rf feeds/packages/net/smartdns
# mv package/new/openwrt-packages/smartdns package/new/smartdns
# rm -rf feeds/luci/applications/luci-app-smartdns
# mv package/new/openwrt-packages/luci-app-smartdns package/new/luci-app-smartdns

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
# bash $GITHUB_WORKSPACE/scripts/openclash.sh arm64

## ShellClash
# bash $GITHUB_WORKSPACE/scripts/ShellClash.sh

## zsh
bash $GITHUB_WORKSPACE/scripts/zsh.sh

## turboacc
bash $GITHUB_WORKSPACE/scripts/turboacc_5_15.sh
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

ls -1 package/new/
