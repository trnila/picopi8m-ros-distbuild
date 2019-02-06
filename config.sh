export DEST=./rootfs
export DISTRO=bionic
export HOSTNAME=picopi
export KERNEL_BRANCH=trn_loadable_imx_rpmsg
export PACKAGES="
  ros-melodic-ros-base
  openssh-server
  vim
  htop
  tmux
  strace
  ranger
  python3-vcstool
  git
  gcc-arm-none-eabi
  minicom
  device-tree-compiler
  i2c-tools
  gdb
"
