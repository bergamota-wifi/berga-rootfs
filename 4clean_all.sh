#!/bin/bash

export CROSS_COMPILE=$(pwd)/tools/realtek/rsdk-4.4.7-4181-EB-2.6.30-0.9.30-m32u-140129/bin/rsdk-linux-

OLDPWD=$(pwd)
TOOLS_DIR=$(pwd)/tools
ROOTFS_DIR=$(pwd)/output/rootfs

# clean output directory
rm -rf output/*

cd linux-2.6.30
make clean
cd rtkload
make clean

cd $TOOLS_DIR

# clean tools directory
for D in *; do
    if [ -d "${D}" ]; then
        cd ${TOOLS_DIR}/${D}
        make clean
        make distclean

        cd $TOOLS_DIR
    fi
done
