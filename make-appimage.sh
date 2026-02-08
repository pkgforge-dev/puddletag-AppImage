#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q puddletag-git | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/pixmaps/puddletag.png
export DESKTOP=/usr/share/applications/puddletag.desktop
export DEPLOY_SYS_PYTHON=1
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun /usr/bin/puddletag

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
