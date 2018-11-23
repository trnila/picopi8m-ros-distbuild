#!/bin/bash
set -e
set -x

. ./common.sh

./build_kernel.sh

# tempory directory for package build
TEMP_DIR=$(mktemp -d)
trap 'rm -r "$TEMP_DIR"' EXIT

cd linux

version=$(./scripts/setlocalversion)

# prepare package
mkdir -p "$TEMP_DIR/linux/DEBIAN"
cat > "$TEMP_DIR/linux/DEBIAN/control" << EOF
Package: linux
Version: 1 
Architecture: arm64
Maintainer: Daniel Trnka
Provides: linux-image, linux-modules
Section: kernel
Description: Modified linux kernel for pico-pi-imx8m
 This package contains the Linux kernel, modules and corresponding other files
EOF

mkdir -p "$TEMP_DIR/linux-headers/DEBIAN"
cat > "$TEMP_DIR/linux-headers/DEBIAN/control" << EOF
Package: linux-headers
Version: 1 
Architecture: arm64
Maintainer: Daniel Trnka
Provides: linux-headers
Section: kernel
Description: Modified linux kernel-headers for pico-pi-imx8m
EOF

# copy kernel, dtb's and modules
mkdir -p "$TEMP_DIR/linux/boot/"
cp -v "./arch/arm64/boot/Image" "$TEMP_DIR/linux/boot/"
cp -v "./"/arch/arm64/boot/dts/freescale/pico*.dtb "$TEMP_DIR/linux/boot/"
make modules_install INSTALL_MOD_PATH="$TEMP_DIR/linux/"

# copy linux-headers
MODULES="$TEMP_DIR/linux-headers/lib/modules/4.9.88${version}/build"
rm "$TEMP_DIR/linux/lib/modules/4.9.88${version}/build" # remove broken symlink from linux package
mkdir -p "$MODULES"
cp -rv {.config,Makefile,scripts,include} "$MODULES"
find . -name 'Kconfig*' -exec install -D {} "$MODULES/{}" \;
find . -name 'Makefile*' -exec install -D {} "$MODULES/{}" \;
find . -name '*.h' -exec install -D {} "$MODULES/{}" \;
# remove unneeded files
rm -rf "$MODULES"/drivers/gpu/drm/{amd,radeo,nouveau}
find "$MODULES" -path '*nouveau*' -delete
for arch in "$MODULES"/arch/*; do
  [[ ! $arch = */arm64/ ]] && rm -r "$arch"
done
find "$MODULES" -type f -name '*.o' -delete

# build packages
dpkg-deb -b "$TEMP_DIR/linux/"
dpkg-deb -b "$TEMP_DIR/linux-headers/"
mv "$TEMP_DIR"/*.deb work/packages/
echo "Packages built successfully"
