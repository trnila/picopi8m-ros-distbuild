#!/bin/sh
set -x
set -e

export PATH=/sbin:/usr/sbin:/bin/:/usr/bin
/debootstrap/debootstrap --second-stage

# copy base files
cp -r /mnt/files/* /

# setup hostname
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
echo "::1 $HOSTNAME" >> /etc/hosts

apt-get install -y gnupg

# install ros
mkdir -p /etc/apt/sources.list.d/
echo "deb http://packages.ros.org/ros-shadow-fixed/ubuntu $DISTRO main" > /etc/apt/sources.list.d/ros.list
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
apt-get update
apt-get install -y ros-melodic-ros-base

apt-get install -y "$PACKAGES" 

# install newer newlib which has support for M4 hard float
mkdir /tmp/debs
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-dev_3.0.0.20180802-2_all.deb -P /tmp/debs/
wget http://mirrors.kernel.org/ubuntu/pool/universe/n/newlib/libnewlib-arm-none-eabi_3.0.0.20180802-2_all.deb -P /tmp/debs/
dpkg -i /tmp/debs/*.deb
