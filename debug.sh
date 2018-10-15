#!/bin/sh

. ./config.sh

mkdir -p "$DEST/mnt"
mount --bind ./work "$DEST/mnt"
PATH=/sbin:/usr/sbin:/bin:/usr/bin chroot $DEST /bin/bash
