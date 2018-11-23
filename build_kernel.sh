#!/bin/sh
set -e
set -x

. ./common.sh

if [ ! -d linux ]; then
  git clone --depth 1 https://github.com/trnila/linux-tn linux
fi

cd linux
git checkout "$KERNEL_BRANCH"

if [ ! -f .config ]; then
  make tn_imx8_defconfig
fi

# make kernel
make "-j$(nproc)"
