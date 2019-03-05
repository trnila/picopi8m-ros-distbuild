# picopi8m-ros-distbuild

## dependencies 
```sh
$ apt-get install -y git make gcc gcc-aarch64-linux-gnu bc binfmt-support qemu-user-static debootstrap xz-utils kmod
```

## build
```sh
$ sudo ./build.sh
```
Built distribution rootfs will be in *./rootfs*.

## download built rootfs
You can also [download](https://gitlab.com/trnila/picopi8m-ros-distbuild/-/jobs/artifacts/master/raw/picopi-ros.rootfs.tar.xz?job=build) the latest successfully built rootfs from gitlab pipeline.
```sh
$ mkdir picopi
$ cd picopi
$ curl -L https://gitlab.com/trnila/picopi8m-ros-distbuild/-/jobs/artifacts/master/raw/picopi-ros.rootfs.tar.xz?job=build | sudo tar -xJ
```

## flash
1. connect jumpers to Serial Download
2. connect usb to PICO-PI-IMX8M USB-C connector
3. power on
4. attach eMMC memory to your pc with:
```sh
$ wget ftp://ftp.technexion.net/development_resources/development_tools/installer/pico-imx8m_mfgtool_20180911.zip
$ unzip pico-imx8m_mfgtool_20180911.zip
$ cd pico-imx8m_mfgtool_20180911/mfgtools
$ chmod +x mfgtoolcli
$ sudo bash ./linux-runvbs.sh mfgtool2-pico_imx8-use_eMMC_as_usb_mass_storage.vbs
```
5. find attached eMMC memory with `lsblk`
6. flash rootfs with
```sh
$ sudo ./flash.sh /dev/sdX
```
7. connect jumpers to previous state and boot
