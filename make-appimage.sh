#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q puddletag-git | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/puddletag.png
export DESKTOP=/usr/share/applications/puddletag.desktop
export DEPLOY_SYS_PYTHON=1
export DEPLOY_OPENGL=1

# Prepare AppDir
quick-sharun /usr/bin/puddletag

#echo "Debloating package..."
#rm -rfv \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/qml                       \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/lib/libQt5Qml.so*         \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/lib/libQt5Quick.so*       \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/lib/libQt5Designer.so*    \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/lib/libQt5XmlPatterns.so* \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/plugins/geoservices       \
#	./AppDir/lib/python*/site-packages/PyQt*/Qt*/plugins/assetimporters

# Turn AppDir into AppImage
quick-sharun --make-appimage

# make appbundle
UPINFO="$(echo "$UPINFO" | sed 's#.AppImage.zsync#*.AppBundle.zsync#g')"
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
./pelf \
	--compression "-C zstd:level=22 -S26 -B8" \
	--appbundle-id="puddletag-$VERSION"       \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--add-appdir ./AppDir                     \
	--output-to ./puddletag-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle
zsyncmake ./*.AppBundle -u ./*.AppBundle
mv -v ./*.AppBundle* ./dist

echo "All Done!"
