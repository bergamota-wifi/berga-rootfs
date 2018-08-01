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
# Berga-CLI
#
######################################

cd $TOOLS_DIR/berga-cli
make clean
make

cp -va $TOOLS_DIR/berga-cli/berga-cli $ROOTFS_DIR/usr/bin/berga-cli
ln -s berga-cli $ROOTFS_DIR/usr/bin/udhcpc-script
