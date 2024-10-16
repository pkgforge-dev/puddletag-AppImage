#!/usr/bin/env bash
# archlinux deps: python musl base-devel patchelf gtk3 libglvnd qt5-base qt5-wayland qt5-svg

mkdir -p puddletag && cd puddletag || exit 1
mkdir build-env
python -m venv build-env
source build-env/bin/activate
python -m pip install --no-cache-dir --upgrade --force --ignore-installed pip
python -m pip install --no-cache-dir --upgrade wheel pyinstaller
python -m pip install --no-cache-dir --upgrade puddletag

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

mkdir dist/puddletag/lib
ldd dist/puddletag/puddletag | grep '> /' | sed 's|.*> /|/|g' \
	| awk '{print $1}' | xargs -I {} cp -f {} dist/puddletag/lib/

# add qt5ct
cp "$(find /usr/lib -type f -name 'libqt5ct.so' -print -quit 2>/dev/null)" dist/puddletag/_internal/PyQt5/Qt5/plugins/platformthemes

shopt -s extglob
patchelf --debug --set-rpath '$ORIGIN/lib' dist/puddletag/puddletag
patchelf --debug --set-rpath '$ORIGIN' dist/puddletag/lib/!(ld-linux-x86-64.so.2)

echo '#!/usr/bin/env sh
SELF_PATH="$(dirname "$(readlink -f "$0")")"
exec "$SELF_PATH/lib/ld-linux-x86-64.so.2" "$SELF_PATH/puddletag" "$@"' > dist/puddletag/AppRun

chmod +x ./dist/puddletag/AppRun

cp ./build-env/share/applications/puddletag.desktop ./dist/puddletag/
cp ./build-env/share/pixmaps/puddletag.png ./dist/puddletag/
ln -s ./puddletag.png ./dist/puddletag/.DirIcon

cd .. && mv ./puddletag/dist/puddletag ./puddletag.AppDir
