#!/bin/sh
set -x
set -e

export PATH=/sbin:/usr/sbin:/bin/:/usr/bin
mount proc /proc -t proc
/debootstrap/debootstrap --second-stage
mount proc /proc -t proc # need to mount it again? otherwise apt-key fails

# allow to login without password
passwd -d root

# copy base files
cp -r /mnt/files/* /

# setup hostname
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
echo "::1 $HOSTNAME" >> /etc/hosts

apt-get update
apt-get install -y gnupg

# install local packages (ie linux kernel)
dpkg -i /mnt/packages/*.deb

# setup ros repository 
mkdir -p /etc/apt/sources.list.d/
echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu $DISTRO main" > /etc/apt/sources.list.d/ros.list
apt-key add /mnt/ros-repo.pub

# install packages
apt-get update
apt-get install -y $PACKAGES 

# install packages required in examples
rosdep init
rosdep update
(cd /root/catkin_ws && rosdep install --from-paths src --ignore-src -r -y)

# install newer newlib which has support for M4 hard float
mkdir /tmp/debs
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb -P /tmp/debs/
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb -P /tmp/debs/
dpkg -i /tmp/debs/*.deb

# cleanup
apt-get clean
rm -rf /var/lib/apt/lists/*
