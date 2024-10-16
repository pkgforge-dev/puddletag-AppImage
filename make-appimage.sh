#!/bin/sh

APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|puddletag-AppImage|latest|*$ARCH.AppImage.zsync"
VERSION="$(./*AppDir/AppRun --version 2>/dev/null | awk 'FNR==1 {print $NF}')"
if [ -z "$VERSION" ]; then
  VERSION=unknown
fi
export VERSION
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$(uname -m)"

wget "$APPIMAGETOOL" -O ./appimagetool && chmod +x ./appimagetool

./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
  -n -u "$UPINFO" ./*AppDir puddletag-"$VERSION"-"$ARCH".AppImage
