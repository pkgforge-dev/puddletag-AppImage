#!/usr/bin/env bash
# archlinux deps: python musl base-devel patchelf gtk3 libglvnd qt5-base qt5-wayland qt5-svg

set -eu

PACKAGE="puddletag"
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$(uname -m)"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"

# MAKE APPDIR AND INSTALL PUDDLETAG
mkdir -p ./"$PACKAGE"/build-env
cd "$PACKAGE"
python -m venv build-env
. build-env/bin/activate
python -m pip install --no-cache-dir --upgrade --force --ignore-installed pip
python -m pip install --no-cache-dir --upgrade wheel pyinstaller
python -m pip install --no-cache-dir --upgrade puddletag

VERSION="$(python -m pip show puddletag 2>/dev/null | awk '/Version:/ {print $2; exit}')"
if [ -z "$VERSION" ]; then
	echo "ERROR: Could not get version of puddletag"
	exit 1
fi
echo "$VERSION" > ~/version

cp /usr/lib/ld-musl-x86_64.so.1 libc.musl-x86_64.so.1

pyinstaller --name puddletag --target-arch x86_64 --strip --noupx \
	--add-data build-env/lib/python*/site-packages/puddlestuff:puddlestuff \
	--add-data /usr/lib/librt.so.1:. \
	--add-data /usr/lib/libm.so.6:. \
	--add-data /usr/lib/libxcb.so.1:. \
	--add-data /usr/lib/libGLX.so.0:. \
	--add-data /usr/lib/libGLdispatch.so.0:. \
	--add-data /usr/lib/libGL.so.1:. \
	--add-data libc.musl-x86_64.so.1:. \
	"$(command -v puddletag)"

mkdir ./dist/puddletag/lib
ldd dist/puddletag/puddletag | grep '> /' | sed 's|.*> /|/|g' \
  | awk '{print $1}' | xargs -I {} cp -f {} dist/puddletag/lib/

# add qt5ct
cp "$(find /usr/lib -type f -name 'libqt5ct.so' -print -quit 2>/dev/null)" \
  dist/puddletag/_internal/PyQt5/Qt5/plugins/platformthemes
cp -r "$(find /usr/lib -type d -regex '.*plugins/styles' -print -quit 2>/dev/null)" \
  dist/puddletag/_internal/PyQt5/Qt5/plugins

shopt -s extglob
patchelf --debug --set-rpath '$ORIGIN/lib' dist/puddletag/puddletag
patchelf --debug --set-rpath '$ORIGIN' dist/puddletag/lib/!(ld-linux-x86-64.so.2)

mv ./dist/puddletag ./AppDir

echo '#!/usr/bin/env sh
HERE="$(dirname "$(readlink -f "$0")")"
[ -f "$APPIMAGE".stylesheet ] && APPIMAGE_QT_THEME="$APPIMAGE.stylesheet"
[ -f "$APPIMAGE_QT_THEME" ] && set -- "$@" "-stylesheet" "$APPIMAGE_QT_THEME"
exec "$HERE/lib/ld-linux-x86-64.so.2" "$HERE/puddletag" "$@"' > ./AppDir/AppRun
chmod +x ./AppDir/AppRun

cp -v ./build-env/share/applications/puddletag.desktop ./AppDir
cp -v ./build-env/share/pixmaps/puddletag.png ./AppDir
ln -s ./puddletag.png ./AppDir/.DirIcon

# MAKE APPIMAGE WITH URUNTIME
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

#Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime \
	-i ./AppDir -o ./"$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage

wget -qO ./pelf "https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" 
chmod +x ./pelf
echo "Generating [dwfs]AppBundle...(Go runtime)"
./pelf --add-appdir ./AppDir \
	--appbundle-id="$PACKAGE-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "$PACKAGE"-"$VERSION"-anylinux-"$ARCH".dwfs.AppBundle

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage
zsyncmake *.AppBundle -u *.AppBundle

mv ./*.AppImage* ../
mv ./*.AppBundle* ../
cd ..
rm -rf ./"$PACKAGE"
echo "All Done!"
