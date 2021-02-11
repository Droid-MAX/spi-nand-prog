#!/bin/sh

PWD=$(pwd)
SRC_DIR=$PWD
BUILD_DIR=$PWD/build
DOWNLOAD_DIR=$PWD/dl
BINDIR=$BUILD_DIR/bin
LIBSDIR=$BUILD_DIR/libs

LIBUSB_URL="https://download.fastgit.org/libusb/libusb/releases/download/v1.0.22/libusb-1.0.22.tar.bz2"
LIBUSB_DIR=""
PKGNAME="spi-nand-prog"

prepare_dirs(){
	if [ ! -d $BUILD_DIR ]; then
		mkdir -p $BUILD_DIR || exit 1
	fi
	if [ ! -d $DOWNLOAD_DIR ]; then
		mkdir -p $DOWNLOAD_DIR || exit 1
	fi
	if [ ! -d $BINDIR ]; then
		mkdir -p $BINDIR || exit 1
	fi
	if [ ! -d $LIBSDIR ]; then
		mkdir -p $LIBSDIR || exit 1
	fi
	return 0
}

download_files(){
	if [ -d $DOWNLOAD_DIR ] && [ ! -d $DOWNLOAD_DIR/libusb-1.0.22 ]; then
		cd $DOWNLOAD_DIR; \
		curl --retry 3 -o libusb-1.0.22.tar.bz2 $LIBUSB_URL; \
		tar xf libusb-1.0.22.tar.bz2
	fi
	LIBUSB_DIR=$(cd $DOWNLOAD_DIR/libusb-1.0.22 && pwd)
	return 0
}

build_depends(){
	if [ -d $LIBUSB_DIR ]; then
		cd $LIBUSB_DIR; \
		./configure --prefix=$LIBSDIR --disable-udev; \
		make clean; \
		make; \
		make install
	fi
	return 0
}

build_target(){
	make -C $SRC_DIR CONFIG_STATIC=yes LIBS_BASE=$LIBSDIR strip && mv $SRC_DIR/$PKGNAME $BINDIR
	return 0
}

#clean_all(){
#	if [ -d $BUILD_DIR ]; then
#		rm -rf $BUILD_DIR || exit 1
#	elif [ -d $DOWNLOAD_DIR ]; then
#		rm -rf $DOWNLOAD_DIR || exit 1
#	fi
#	return 0
#}

prepare_dirs
download_files
build_depends
build_target
#clean_all
