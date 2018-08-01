#!/bin/bash

OLDPWD=$(pwd)
TOOLS_DIR=$(pwd)/tools
ROOTFS_DIR=$(pwd)/output/rootfs


######################################
#
# rootfs image file
#
######################################

# SPI flash layout
#
# /dev/mtdblock0 -> bootloader
# /dev/mtdblock1 -> hwsettings
# /dev/mtdblock2 -> bergamota configs
# /dev/mtdblock3 -> kernel
# /dev/mtdblock4 -> rootfs
#



find $ROOTFS_DIR | grep .gitkeep | xargs rm -f

rm output/squashfs.o
rm output/root.bin

$TOOLS_DIR/realtek/mksquashfs $ROOTFS_DIR output/squashfs.o -comp lzma -b 1048576 -always-use-fragments -pf $TOOLS_DIR/squashfs-pf-list.txt -all-root
$TOOLS_DIR/realtek/cvimg root output/squashfs.o output/root.bin F0000 0x150000

$TOOLS_DIR/realtek/mgbin -c -o output/bergamota.bin \
                               tools/bootcode_rtl8196d/boot/Output/boot.bin \
                               linux-2.6.30/rtkload/linux.bin \
                               output/root.bin
