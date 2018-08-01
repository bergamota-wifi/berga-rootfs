#!/bin/bash

export DIR_ROOT=$(pwd)
export CROSS_COMPILE=$(pwd)/tools/realtek/rsdk-4.4.7-4181-EB-2.6.30-0.9.30-m32u-140129/bin/rsdk-linux-

cd linux-2.6.30/
make clean
make

cd rtkload
make rtk-clean
make
