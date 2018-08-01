#!/bin/bash

#
# Bergamota-ng build scripts (c) 2018 Cassiano Martin <cassiano@polaco.pro.br>
# Copyright (c) 2018 Cassiano Martin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

######################################
#
# CrossTool exports / Directories
#
######################################

export ARCH=mips
export CROSS_COMPILE=$(pwd)/tools/realtek/rsdk-4.4.7-4181-EB-2.6.30-0.9.30-m32u-140129/bin/rsdk-linux-
export PATH=$PATH:$(pwd)/tools/realtek/rsdk-4.4.7-4181-EB-2.6.30-0.9.30-m32u-140129/bin

OLDPWD=$(pwd)
TOOLS_DIR=$(pwd)/tools
OUTPUT_DIR=$(pwd)/output
ROOTFS_DIR=$OUTPUT_DIR/rootfs

# iptables configure script does not detect cross compiler, need to
# force ambient variables to get it work right.
export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}"g++"
export AR=${CROSS_COMPILE}"ar"
export AS=${CROSS_COMPILE}"as"
export RANLIB=${CROSS_COMPILE}"ranlib"
export LD=${CROSS_COMPILE}"ld"
export STRIP=${CROSS_COMPILE}"strip"
export CROSS_PREFIX=mips-linux-
export CFLAGS="-march=4181 -Os -ffunction-sections -fdata-sections"
export LDFLAGS="-Wl,--gc-sections"
export CPPFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS



######################################
#
# Skeleton filesystem
#
######################################

# clean output directory
rm -rf output/*

cp -va skeleton $ROOTFS_DIR


######################################
#
# RLX bootloader
#
######################################

cd $TOOLS_DIR/bootcode_rtl8196d
make clean
make all



######################################
#
# busybox
#
######################################

cd $TOOLS_DIR/busybox-1.28.4
cp $TOOLS_DIR/config_busybox $TOOLS_DIR/busybox-1.28.4/.config
make clean
make
make install



######################################
#
# iproute2
#
######################################

cd $TOOLS_DIR/iproute2-2.6.29-1
make clean
make

cp $TOOLS_DIR/iproute2-2.6.29-1/ip/ip $ROOTFS_DIR/sbin/ip
cp $TOOLS_DIR/iproute2-2.6.29-1/tc/tc $ROOTFS_DIR/sbin/tc



######################################
#
# iptables
#
######################################

cd $TOOLS_DIR/iptables-1.4.4

make distclean
./configure --prefix=$ROOTFS_DIR/usr --host=mips-linux --target=mips-linux --with-ksource=../linux-2.6.30 --enable-static --disable-shared CFLAGS=-Os
make depend
make

cp $TOOLS_DIR/iptables-1.4.4/ip6tables-static $ROOTFS_DIR/usr/sbin/ip6tables-static
cp $TOOLS_DIR/iptables-1.4.4/iptables-static $ROOTFS_DIR/usr/sbin/iptables-static

ln -s iptables-static $ROOTFS_DIR/usr/sbin/iptables
ln -s iptables-static $ROOTFS_DIR/usr/sbin/iptables-save
ln -s ip6tables-static $ROOTFS_DIR/usr/sbin/ip6tables
ln -s ip6tables-static $ROOTFS_DIR/usr/sbin/ip6tables-save



######################################
#
# Wireless tools v.25
#
######################################

cd $TOOLS_DIR/wireless_tools.25
make clean
make

cp -va $TOOLS_DIR/wireless_tools.25/iwconfig $ROOTFS_DIR/usr/sbin/iwconfig
cp -va $TOOLS_DIR/wireless_tools.25/iwevent $ROOTFS_DIR/usr/sbin/iwevent
cp -va $TOOLS_DIR/wireless_tools.25/iwgetid $ROOTFS_DIR/usr/sbin/iwgetid
cp -va $TOOLS_DIR/wireless_tools.25/iwlist $ROOTFS_DIR/usr/sbin/iwlist
cp -va $TOOLS_DIR/wireless_tools.25/iwpriv $ROOTFS_DIR/usr/sbin/iwpriv
cp -va $TOOLS_DIR/wireless_tools.25/iwspy $ROOTFS_DIR/usr/sbin/iwspy
cp -va $TOOLS_DIR/wireless_tools.25/libiw.so.25 $ROOTFS_DIR/lib/libiw.so.25
ln -s /lib/libiw.so.25 $ROOTFS_DIR/lib/libiw.so



######################################
#
# DNSmasq
#
######################################

cd $TOOLS_DIR/dnsmasq-2.70
make clean
make

cp -va $TOOLS_DIR/dnsmasq-2.70/src/dnsmasq $ROOTFS_DIR/usr/bin/dnsmasq



######################################
#
# Zlib
#
######################################

cd $TOOLS_DIR/zlib-1.2.8
make clean
LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mips-linux- \
./configure --prefix=/
make
make install DESTDIR=$OUTPUT_DIR/install

cp -va $OUTPUT_DIR/install/lib/libz.so* $ROOTFS_DIR/lib



######################################
#
# OpenSSL
#
######################################

cd $TOOLS_DIR/openssl-1.0.1j
make clean

./Configure linux-mips \
-ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/ shared zlib-dynamic \
--with-zlib-lib=$OUTPUT_DIR/install/lib \
--with-zlib-include=$OUTPUT_DIR/install/include

make CC=mips-linux-gcc AR="mips-linux-ar r" RANLIB=mips-linux-ranlib
make install CC=mips-linux-gcc AR="mips-linux-ar r" RANLIB=mips-linux-ranlib INSTALLTOP=$OUTPUT_DIR/install OPENSSLDIR=$OUTPUT_DIR/install/ssl



######################################
#
# Libevent (not installed to ROOTFS, statically linked to TOR)
#
######################################

cd $TOOLS_DIR/libevent-2.0.21-stable

make clean
make distclean

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mips-linux- \
./configure --prefix=/ --host=mips-linux --target=mips-linux --enable-static --disable-shared

make
make install DESTDIR=$OUTPUT_DIR/install



######################################
#
# Dropbear
#
######################################

cd $TOOLS_DIR/dropbear-2018.76
make clean
make distclean
./configure --host=mips-linux --target=mips-linux --with-zlib=$TOOLS_DIR/zlib-1.2.8 --disable-harden --disable-openpty
make PROGRAMS="dropbear dropbearkey scp" MULTI=1

cp -va $TOOLS_DIR/dropbear-2018.76/dropbearmulti $ROOTFS_DIR/usr/bin/dropbearmulti
ln -s dropbearmulti $ROOTFS_DIR/usr/bin/dropbear
ln -s dropbearmulti $ROOTFS_DIR/usr/bin/dropbearkey
ln -s dropbearmulti $ROOTFS_DIR/usr/bin/scp



######################################
#
# Tor
#
######################################

# statically linking openssl reduces binary size

cd $TOOLS_DIR/tor-0.2.5.16
LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mips-linux- \
./configure --host=mips-linux --target=mips-linux \
--enable-static-libevent \
--with-libevent-dir=$OUTPUT_DIR/install \
--enable-static-openssl \
--with-openssl-dir=$OUTPUT_DIR/install \
--with-zlib-dir=$OUTPUT_DIR/install \
--disable-asciidoc \
--enable-static-tor \
--disable-linker-hardening \
--disable-gcc-hardening \
--disable-seccomp \
--disable-largefile \
--disable-tool-name-check

make

cp -va $TOOLS_DIR/tor-0.2.5.16/src/or/tor $ROOTFS_DIR/usr/bin/tor



######################################
#
# mbedTLS
#
######################################

cd $TOOLS_DIR/mbedtls-2.11.0
make clean
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DUSE_SHARED_MBEDTLS_LIBRARY=On .
make
make install DESTDIR=$OUTPUT_DIR/install

cp -va $OUTPUT_DIR/install/usr/lib/libmbed*.so* $ROOTFS_DIR/lib



######################################
#
# OpenVPN
#
######################################

cd $TOOLS_DIR/openvpn-2.4.0

make clean

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mips-linux- \
MBEDTLS_CFLAGS="-I$OUTPUT_DIR/install/usr/include/" \
MBEDTLS_LIBS="-L$OUTPUT_DIR/install/usr/lib/ -lmbedtls -lmbedx509 -lmbedcrypto" \
./configure --prefix=/ --host=mips-linux \
            --target=mips-linux \
            --with-crypto-library=mbedtls \
            --disable-debug \
            --enable-small \
            --disable-management \
            --disable-plugins \
            --disable-lz4 \
            --disable-lzo \
            --enable-iproute2

make

cp -va $TOOLS_DIR/openvpn-2.4.0/src/openvpn/openvpn $ROOTFS_DIR/usr/bin/openvpn



######################################
#
# Berga-CLI
#
######################################

cd $TOOLS_DIR/berga-cli
make clean
make

cp -va $TOOLS_DIR/berga-cli/berga-cli $ROOTFS_DIR/usr/bin/berga-cli
ln -s berga-cli $ROOTFS_DIR/usr/bin/udhcpc-script



######################################
#
# shared libraries / uClibc
#
######################################

cp -va $TOOLS_DIR/realtek/rsdk-4.4.7-4181-EB-2.6.30-0.9.30-m32u-140129/lib/*.so* $ROOTFS_DIR/lib
rm -f $ROOTFS_DIR/lib/libstdc++*
rm -f $ROOTFS_DIR/lib/libntfs-3g*

$STRIP -s $ROOTFS_DIR/usr/bin/*
$STRIP -s $ROOTFS_DIR/usr/sbin/*
$STRIP -s $ROOTFS_DIR/bin/*
$STRIP -s $ROOTFS_DIR/sbin/*

$STRIP --strip-unneeded $ROOTFS_DIR/lib/*.so*
