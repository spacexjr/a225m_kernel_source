#!/bin/bash

export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y a22_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j16

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image

cp out/arch/arm64/boot/Image AnyKernel3/Image

KERNEL_RELEASE=$(sed -n 's/^#define UTS_RELEASE "\(.*\)"$/\1/p' out/include/generated/utsrelease.h)
ZIP_NAME=SpacialKernel4.14-$(date +%Y%m%d)-${KERNEL_RELEASE}.zip

rm -f "$ZIP_NAME"
cd AnyKernel3
zip -r9 "../$ZIP_NAME" . -x .git -x README.md -x LICENSE -x "*.zip"
cd ..

echo "Zip gerado: $ZIP_NAME"
