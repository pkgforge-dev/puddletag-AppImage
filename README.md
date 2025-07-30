# puddletag-AppImage

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/puddletag-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/puddletag-AppImage/actions/workflows/blank.yml/badge.svg)](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)

* [Latest Stable Release](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)

Made it since the maintainer doesn't want to create one. [1](https://github.com/puddletag/puddletag/issues/919#issuecomment-2211231931) [2](https://github.com/puddletag/puddletag/issues/408#issuecomment-2026230760)

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks.

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i puddletag` or `appman -i puddletag`

* [dbin](https://github.com/xplshn/dbin) `dbin install puddletag.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install puddletag`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/) 
