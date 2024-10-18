#!/usr/bin/env bash
# archlinux deps: python musl base-devel patchelf gtk3 libglvnd qt5-base qt5-wayland qt5-svg

# make appdir
mkdir -p ./puddletag/build-env && cd puddletag || exit 1
python -m venv build-env && . build-env/bin/activate || exit 1
python -m pip install --no-cache-dir --upgrade --force --ignore-installed pip
python -m pip install --no-cache-dir --upgrade wheel pyinstaller
python -m pip install --no-cache-dir --upgrade puddletag

VERSION="$(python -m pip show puddletag 2>/dev/null | awk '/Version:/ {print $2; exit}')"

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

mv ./dist/puddletag ./puddletag.AppDir

echo '#!/usr/bin/env sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/lib/ld-linux-x86-64.so.2" "$HERE/puddletag" "$@"' > ./puddletag.AppDir/AppRun
chmod +x ./puddletag.AppDir/AppRun

cp ./build-env/share/applications/puddletag.desktop ./puddletag.AppDir
cp ./build-env/share/pixmaps/puddletag.png ./puddletag.AppDir
ln -s ./puddletag.png ./puddletag.AppDir/.DirIcon

# bug?
# if not done for some reason appimagetool will fail to find the AppDir
# and yes I checked $PWD just in case and that is not the issue
mv ./puddletag.AppDir ../ && cd ../ || exit 1

# make appimage
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$(uname -m)"
APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|puddletag-AppImage|latest|*$ARCH.AppImage.zsync"
[ -z "$VERSION" ] && VERSION=unknown
export VERSION

wget "$APPIMAGETOOL" -O ./appimagetool && chmod +x ./appimagetool

./appimagetool --comp zstd \
	--mksquashfs-opt -Xcompression-level --mksquashfs-opt 22 \
	-n -u "$UPINFO" ./puddletag.AppDir puddletag-"$VERSION"-"$ARCH".AppImage

echo "All Done!"
