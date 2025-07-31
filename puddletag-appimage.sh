#!/bin/sh

set -ex

ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
ICON="https://raw.githubusercontent.com/puddletag/puddletag/8a1d2badc76340f5cca84e938919707cc891c4ce/puddlestuff/data/appicon.svg"

# github actions doesn't set USER
export USER=USER

# Prepare AppDir
mkdir -p ./AppDir && (
	cd ./AppDir
	# ADD LIBRARIES
	wget --retry-connrefused --tries=30 "$SHARUN" -O ./sharun-aio
	chmod +x ./sharun-aio
	xvfb-run -a -- \
		./sharun-aio l         \
		--strip                \
		--with-hooks           \
		--python-ver 3.12      \
		--python-pkg puddletag \
		--dst-dir ./ sharun -- puddletag
	rm -f ./sharun-aio

	./sharun -g

	# add qt5ct for custom theming
	echo "Adding qt5ct..."
	mkdir -p \
		./lib/python*/site-packages/PyQt5/Qt5/plugins/styles \
		./lib/python*/site-packages/PyQt5/Qt5/plugins/platformthemes

	cp -v /usr/lib/libqt5ct*                              ./lib
	cp -v /usr/lib/qt/plugins/styles/libqt5ct-style.so    ./lib/python*/site-packages/PyQt5/Qt5/plugins/styles
	cp -v /usr/lib/qt/plugins/platformthemes/libqt5ct.so  ./lib/python*/site-packages/PyQt5/Qt5/plugins/platformthemes

	echo "Adding icon and desktop entry..."
	wget "$ICON" -O ./puddletag.svg
	cp -v ./puddletag.svg ./.DirIcon

	cat <<-'KEK' > ./AppRun
	#!/bin/sh
	CURRENTDIR="$(cd "${0%/*}" && echo "$PWD")"
	export PATH="$CURRENTDIR/bin:$PATH"
	[ -f "$APPIMAGE".stylesheet ] && APPIMAGE_QT_THEME="$APPIMAGE.stylesheet"
	[ -f "$APPIMAGE_QT_THEME" ] && set -- "$@" "-stylesheet" "$APPIMAGE_QT_THEME"
	exec "$CURRENTDIR"/bin/puddletag "$@"
	KEK
	chmod +x ./AppRun

	cat <<-'KEK' > ./puddletag.desktop
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=puddletag
	TryExec=puddletag
	MimeType=inode/directory;audio/x-ape;audio/x-wavpack;audio/x-musepack;audio/mpeg;audio/x-aiff;audio/x-dsf;audio/x-dff;audio/mp4;audio/x-m4a;video/mp4;video/x-m4v;audio/ogg;audio/flac;audio/x-opus+ogg;audio/x-ms-wma;video/x-ms-wmv;video/x-ms-asf;
	Exec=puddletag %F
	Icon=puddletag
	GenericName=Audio Tag Editor
	Categories=AudioVideo;Audio;Qt;
	StartupWMClass=puddletag
	Keywords=tagger;mp3tag;music;
	KEK
)

echo "Debloating package..."
rm -rfv \
	./AppDir/lib/python*/site-packages/PyQt*/Qt*/qml                   \
	./AppDir/lib/python*/site-packages/PyQt*/Qt*/plugins/geoservices   \
	./AppDir/lib/python*/site-packages/PyQt*/Qt*/plugins/assetimporters

VERSION="$(xvfb-run -a -- ./AppDir/AppRun --version | awk '{print $NF; exit}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME"      -O  ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O  ./uruntime-lite
chmod +x ./uruntime*

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime \
	--appimage-mkdwarfs -f               \
	--set-owner 0 --set-group 0          \
	--no-history --no-create-timestamp   \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime-lite               \
	-i ./AppDir                          \
	-o ./puddletag-"$VERSION"-anylinux-"$ARCH".AppImage

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

zsyncmake ./*.AppImage -u ./*.AppImage
zsyncmake ./*.AppBundle -u ./*.AppBundle

mkdir -p ./dist
mv -v ./*.AppImage*  ./dist
mv -v ./*.AppBundle* ./dist

echo "All Done!"
