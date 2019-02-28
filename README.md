# picopi8m-ros-distbuild

## dependencies 
```sh
$ apt-get install -y git make gcc gcc-aarch64-linux-gnu bc binfmt-support qemu-user-static debootstrap xz-utils
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
