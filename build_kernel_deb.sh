#!/bin/bash
set -e
set -x

DEBUG=0
if [ "$1" == "-d" ]; then
  DEBUG=1
fi

. ./common.sh

if [ $DEBUG -eq 0 ]; then
  ./build_kernel.sh
fi

# tempory directory for packages build
TEMP_DIR=$(mktemp -d)
trap 'rm -r "$TEMP_DIR"' EXIT

build() {
  name="$1"

  package_name="${name%*-dev}-picopim8"
  package_name="${package_name//_/-}"

  if [[ "$name" == *-dev ]]; then
    package_name="${package_name}-dev"
  fi

  dst="$TEMP_DIR/$package_name"

  mkdir -p "$dst/DEBIAN/"
  cat > "$dst/DEBIAN/control" << EOF
Package: $package_name
Version: ${version:1}
Architecture: arm64
Maintainer: Daniel Trnka
Section: kernel
EOF

"build_$name" "$dst"
dpkg-deb -b "$dst"
}

build_linux_image() {
  dst="$1"

  cat >> "$dst/DEBIAN/control" << EOF
Provides: linux-image, linux-modules
Description: Modified linux kernel for pico-pi-imx8m
 This package contains the Linux kernel, modules and device tree blobs
EOF

install -Dv ./arch/arm64/boot/Image "$dst/boot/Image"
install -Dv ./arch/arm64/boot/dts/freescale/pico*.dtb "$dst/boot/"
make modules_install INSTALL_MOD_PATH="$dst"
rm "$dst/lib/modules/4.9.88${version}/build" # remove broken symlink
rm "$dst/lib/modules/4.9.88${version}/source" # remove broken symlink
}

build_linux_headers() {
  dst="$1"

  cat >> "$dst/DEBIAN/control" << EOF
Provides: linux-headers
Description: Modified linux kernel-headers used for building out-of-tree kernel modules for pico-pi-imx8m
EOF

  # populate aarch64-linux-gnu-gcc compiler as gcc and add to the PATH
  # so we can build scripts for arm target
  mkdir "$dst/fake_bin"
  for file in $(dirname "$(which aarch64-linux-gnu-gcc)")/aarch64-linux-gnu-*; do
    name=$(basename "$file")
    ln -s $file "$dst/fake_bin/${name#aarch64-linux-gnu-}"
  done
  export PATH="$dst/fake_bin:$PATH"

  make M=scripts clean
  export QEMU_LD_PREFIX=/usr/aarch64-linux-gnu/
  make scripts
  rm -rf "$dst/fake_bin"

  MODULES="$dst/lib/modules/4.9.88${version}/build"
  mkdir -p "$MODULES"
  (
  find . -name 'Kconfig*' -o -name 'Makefile*' -o -name '*.pl';
  find arch/{arm,arm64}/include include scripts -type f 
  find arch/arm64 -name module.lds -o -name Kbuild.platforms -o -name Platform
  find $(find arch/arm64 -name include -o -name scripts -type d) -type f
  find arch/arm64/include Module.symvers include scripts -type f
  find .config
  ) | tar -c -T - -f - | (cd "$MODULES"; tar -xf -)

  make M=scripts clean
}

build_linux_libc_dev() {
  dst="$1"

  cat >> "$dst/DEBIAN/control" << EOF
Provides: linux-libc-dev
Description: Linux support headers for userspace development
 This package provides userspaces headers from the Linux kernel.  These
 headers are used by the installed headers for GNU libc and other system
 libraries.
EOF

make headers_install ARCH=arm64 INSTALL_HDR_PATH="$dst/usr"
}

cd linux
version=$(./scripts/setlocalversion)

build linux_image
build linux_headers
build linux_libc_dev

du -sh "$TEMP_DIR"/*.deb 
cp "$TEMP_DIR/"*.deb ../work/packages/

if [ "$DEBUG" -eq 1 ]; then
  echo Entering build directory.....
  cd "$TEMP_DIR"
  bash
fi
