#!/bin/sh
set -e
set -x

. ./common.sh

if [ ! -d linux ]; then
  git clone --depth 1 https://github.com/trnila/linux-tn linux
  git checkout "$KERNEL_BRANCH"
fi

if [ ! -f linux/.config ]; then
  make -C linux tn_imx8_defconfig
fi

# make kernel
make -C linux "-j$(nproc)"
