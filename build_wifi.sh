#!/bin/sh
set -ex

. ./common.sh

DIR="qcacld-2.0"

if [ ! -d "$DIR" ]; then
  git clone https://github.com/TechNexion/qcacld-2.0.git "$DIR" -b tn-CNSS.LEA.NRT_3.0
fi

cd "$DIR"

KERNEL_SRC=../linux \
CONFIG_QCA_LL_TX_FLOW_CT=1 \
CONFIG_WLAN_FEATURE_FILS=y \
CONFIG_FEATURE_COEX_PTA_CONFIG_ENABLE=y \
CONFIG_QCA_SUPPORT_TXRX_DRIVER_TCP_DEL_ACK=y \
CONFIG_WLAN_WAPI_MODE_11AC_DISABLE=y \
TARGET_BUILD_VARIANT=user \
CONFIG_NON_QC_PLATFORM=y \
CONFIG_HDD_WLAN_WAIT_TIME=10000 \
make -j4

KERNEL_SRC=../linux \
INSTALL_MOD_PATH=../rootfs/ make modules_install
