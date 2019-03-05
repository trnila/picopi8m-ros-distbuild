#!/bin/bash
set -e
disk=$1
rootfs=${2:-"https://gitlab.com/trnila/picopi8m-ros-distbuild/-/jobs/artifacts/master/raw/picopi-ros.rootfs.tar.xz?job=build"}

if [ -z "$disk" ]; then
  (
    echo "Usage: flash.sh /dev/sdX url_or_path/to/rootfs.tar.xz"
    echo "This script will DESTROY ALL DATA on /dev/sdx!"
  ) 1>&2
  exit 1 
fi

# make partions
(
  echo o                    # create dos partion table
  echo -e "n\np\n1\n\n+64M" # add primary partion 1
  echo -e "n\np\n2\n\n\n"   # add primary partion 2 with rest of space
  echo w                    # save table
) | fdisk -W always "$disk" || true # it fails to reread - busy

# re-read partions
partprobe "$disk"

mkfs.fat "$disk"1
mkfs.ext4 "$disk"2

mkdir -p mnt
trap 'umount mnt/boot; umount mnt' EXIT

# mount partions
mount "$disk"2 mnt
mkdir -p mnt/boot
mount "$disk"1 mnt/boot

# extract rootfs
cd mnt;
if [[ "$rootfs" == https://* ]]; then
  curl -L "$rootfs" | tar -xJ
else
  tar -xf "$rootfs"
fi

# update fstab
echo "/dev/mmcblk0p1 /boot vfat defaults 0 0" >> etc/fstab 

sync
echo flash complete
