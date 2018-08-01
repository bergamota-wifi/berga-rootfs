#!/bin/bash

sshpass -v -p root scp output/squashfs.o root@172.16.1.1:/tmp/squashfs.o
sshpass -v -p root scp linux-2.6.30/rtkload/linux.bin root@172.16.1.1:/tmp/linux.bin

sshpass -v -p root ssh root@172.16.1.1 <<'ENDSSH'
/usr/sbin/flashcp -v /tmp/squashfs.o /dev/mtd4
/usr/sbin/flashcp -v /tmp/linux.bin /dev/mtd3
/sbin/reboot
ENDSSH
