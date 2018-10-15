#!/bin/sh
set -x
set -e

. ./config.sh

DEST=$(realpath "$DEST")

if [ -d "$DEST" ]; then
  echo "Directory $DEST already exists, refusing to build"
  exit 1
fi


# build kernel
if [ ! -d linux ]; then
  git clone https://github.com/trnila/linux-tn linux
fi
(
  cd linux
  git checkout "$KERNEL_BRANCH"
  export CROSS_COMPILE=aarch64-linux-gnu-
  export ARCH=arm64
  make tn_imx8_defconfig
  make "-j$(nproc)"

  mkdir -p "$DEST/boot"
  cp -v arch/arm64/boot/Image "$DEST/boot"
  cp -v arch/arm64/boot/dts/freescale/*.dtb "$DEST/boot"
  make modules_install INSTALL_MOD_PATH="$DEST/"
)


cleanup() {
  umount "$DEST/mnt"
}
trap cleanup EXIT

debootstrap --foreign --arch arm64 "$DISTRO" "$DEST"  http://ports.ubuntu.com/
mkdir -p "$DEST/mnt"
mount --bind ./work "$DEST/mnt"
chroot "$DEST" /bin/sh /mnt/setup.sh

echo "Successfully built to $DEST"
