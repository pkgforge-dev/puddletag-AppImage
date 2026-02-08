<div align="center">

# puddletag-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/puddletag-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/puddletag-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/puddletag-AppImage)](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest)

<p align="center">
  <img src="https://raw.githubusercontent.com/puddletag/puddletag/da6fd539acd8871429605332dadab7f4a90c8e96/puddlestuff/data/appicon.svg" width="128" />
</p>


| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/puddletag-AppImage/releases/latest) | [Click here](https://github.com/pkgforge-dev/Anylinux-AppImages) |

Made it since the dev doesn't want to create one and is a total asshole. [1](https://github.com/puddletag/puddletag/issues/919#issuecomment-2211231931) [2](https://github.com/puddletag/puddletag/issues/408#issuecomment-2026230760)

</div>

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks. 

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i puddletag` or `appman -i puddletag`

* [dbin](https://github.com/xplshn/dbin) `dbin install puddletag.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install puddletag`

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)
