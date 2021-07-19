#!/bin/bash

# To set openocd build-dir, source-dir
WORK_DIR=`readlink -f ./`
SOURCE_DIR=$WORK_DIR/src
BUILD_DIR=$WORK_DIR/build
UNAMESTR=`uname`

# Setup Source path
LIBUSB_SRC=$SOURCE_DIR/libusb
OPENOCD_SRC=$SOURCE_DIR/openocd
OPENOCD_ADAPTER_SRC=$SOURCE_DIR/openocd_adapters


# Clean build/source folder
rm -rf $BUILD_DIR


# Build libusb
printf "\n\n\nBuild libusb\n"
cd $LIBUSB_SRC
./bootstrap.sh
mkdir -p $BUILD_DIR/build/libusb
cd $BUILD_DIR/build/libusb
$LIBUSB_SRC/configure --prefix=$BUILD_DIR/usr \
	PKG_CONFIG_LIBDIR=$BUILD_DIR/usr/lib/pkgconfig \
	--disable-shared \
	--disable-udev \
	--disable-timerfd \
	CFLAGS="-m32" CXXFLAGS="-m32"
make install -j8


# Build OpenOCD
printf "\n\n\nBuild OpenOCD\n"
cd $OPENOCD_SRC
./bootstrap
mkdir -p $BUILD_DIR/build/openocd
cd $BUILD_DIR/build/openocd
$OPENOCD_SRC/configure --prefix=$BUILD_DIR/usr \
	PKG_CONFIG_LIBDIR=$BUILD_DIR/usr/lib/pkgconfig \
	--disable-stlink \
	--disable-ti-icdi \
	--disable-jlink \
	--disable-osbdm \
	--disable-opendous \
	--disable-vsllink \
	--disable-usbprog \
	--disable-rlink \
	--disable-ulink \
	--disable-armjtagew \
	--disable-usb-blaster-2 \
	--enable-ftdi \
	--enable-aice \
	--disable-werror \
	CFLAGS="-m32" CXXFLAGS="-m32"
make -j8
make install-strip


# Build openocd_adapter
printf "\n\n\nBuild openocd_adapter\n"
cd $OPENOCD_ADAPTER_SRC
./bootstrap
mkdir -p $BUILD_DIR/build/openocd_adapter
cd $BUILD_DIR/build/openocd_adapter
$OPENOCD_ADAPTER_SRC/configure --prefix=$BUILD_DIR/usr \
	PKG_CONFIG_LIBDIR=$BUILD_DIR/usr/lib/pkgconfig \
	LDFLAGS="-L$BUILD_DIR/usr/lib" \
	CFLAGS="-m32 -I$BUILD_DIR/usr/include" CXXFLAGS="-m32 -I$BUILD_DIR/usr/include"
make install-strip -j8

