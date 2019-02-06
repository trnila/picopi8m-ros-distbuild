#!/bin/sh
set -x
set -e

. ./config.sh

DEST=$(realpath "$DEST")

if [ -d "$DEST" ]; then
  echo "Directory $DEST already exists, refusing to build"
  exit 1
fi

./build_kernel_deb.sh

cleanup() {
  umount "$DEST/mnt" || true
  umount "$DEST/proc" || true
}
trap cleanup EXIT

debootstrap --foreign --arch arm64 "$DISTRO" "$DEST"  http://ports.ubuntu.com/
mkdir -p "$DEST/mnt"
mount --bind ./work "$DEST/mnt"
rm -f "$DEST/proc" || true
mkdir -p "$DEST/proc"
chroot "$DEST" /bin/sh /mnt/setup.sh

# install m4sdk
git clone https://github.com/trnila/picopi-m4sdk /opt/freertos-tn

# package rootfs
(cd rootfs && tar --one-file-system -cJf ../picopi-ros.rootfs.tar.xz .)

echo "Successfully built to $DEST"
