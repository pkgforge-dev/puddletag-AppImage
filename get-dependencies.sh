#!/bin/sh

set -eux

ARCH="$(uname -m)"

case "$ARCH" in
	'x86_64')  PKG_TYPE='x86_64.pkg.tar.zst';;
	'aarch64') PKG_TYPE='aarch64.pkg.tar.xz';;
	''|*) echo "Unknown arch: $ARCH"; exit 1;;
esac

LIBXML_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/libxml2-iculess-$PKG_TYPE"
OPUS_URL="https://github.com/pkgforge-dev/llvm-libs-debloated/releases/download/continuous/opus-nano-$PKG_TYPE"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel        \
	curl              \
	fontconfig        \
	freetype2         \
	git               \
	libxcb            \
	libxcursor        \
	libxi             \
	libxkbcommon      \
	libxkbcommon-x11  \
	libxrandr         \
	libxtst           \
	pulseaudio        \
	pulseaudio-alsa   \
	qt5-base          \
	qt5ct             \
	wget              \
	xorg-server-xvfb  \
	zsync


echo "Installing debloated pckages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$LIBXML_URL" -O  ./libxml2.pkg.tar.zst
wget --retry-connrefused --tries=30 "$OPUS_URL"   -O  ./opus.pkg.tar.zst

pacman -U --noconfirm ./*.pkg.tar.zst
rm -f ./*.pkg.tar.zst

# This app will dlopen mesa, even though it is not needed at all since it is a qt app
pacman -Rdd --noconfirm mesa

echo "All done!"
echo "---------------------------------------------------------------"
