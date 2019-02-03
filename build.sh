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
  umount "$DEST/mnt"
  umount "$DEST/proc"
}
trap cleanup EXIT

debootstrap --foreign --arch arm64 "$DISTRO" "$DEST"  http://ports.ubuntu.com/
mkdir -p "$DEST/mnt"
mount --bind ./work "$DEST/mnt"
rm -f "$DEST/proc" || true
mkdir -p "$DEST/proc"
mount -t proc none "$DEST/proc"
chroot "$DEST" /bin/sh /mnt/setup.sh
(cd rootfs && tar -cJf ../picopi-ros.rootfs.tar.xz .)

echo "Successfully built to $DEST"
