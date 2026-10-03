# ReSukiSU for Samsung A22 (MT6768)

[![Kernel Version](https://img.shields.io/badge/Kernel-4.14.186-blue)]()
[![Root Solution](https://img.shields.io/badge/ReSukiSU-v4.2.0--rc3-green)]()
[![Platform](https://img.shields.io/badge/Platform-MT6768-red)]()
[![Android Version](https://img.shields.io/badge/Android-11--13-lightgrey)]()

Custom kernel source for **Samsung Galaxy A22 (A225F/SM-A225M)** with **ReSukiSU** integrated via manual hooks.

---

## 📋 Features

### ReSukiSU
- ✅ **Kernel-level root access** - Hidden from most detection methods
- ✅ **Allowlist management** - Grant root access per-app
- ✅ **ReSukiSU Manager support** - Official manager plus MKSU, RKSU, KOWSU, SukiSU-Ultra
- ✅ **Manual hook mode** - Required for non-GKI kernels such as this one
- ✅ **Module support** - Load KSU modules
- ✅ **sulog** - Built-in superuser call logging

### Hook mode

This is a non-GKI 4.14 kernel, so ReSukiSU runs in **manual hook** mode
(`CONFIG_KSU_MANUAL_HOOK=y`). The following hooks are wired in the kernel source:

| Hook | File |
|------|------|
| `ksu_handle_execveat` / `ksu_handle_post_execveat` | `fs/exec.c` |
| `ksu_handle_faccessat` | `fs/open.c` |
| `ksu_handle_stat` | `fs/stat.c` |
| `ksu_handle_newfstat_ret` | `fs/stat.c` |
| `ksu_handle_sys_reboot` | `kernel/reboot.c` |
| setuid / init rc / input | automatic via LSM and input handler |

### KPM (Kernel Package Manager)
- ✅ **KPM Module Loader** - Load .kpm modules at boot
- ✅ **KPatch-Next Compatible** - Full kernel patching support
- ✅ **KALLSYMS_ALL Enabled** - All kernel symbols exported for patching

### Additional Features
- ✅ **Custom kernel version** - `4.14.186-爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## ⚠️ susfs is NOT enabled

susfs is **not** built into this kernel (`CONFIG_KSU_SUSFS` is off), so none of the
susfs hiding features are available (SUS_PATH, SUS_MOUNT, SUS_KSTAT, kallsyms hiding,
uname spoofing, SUS_MAP, open redirect, AVC log spoofing).

The reason is an upstream incompatibility, not a missing patch:

- ReSukiSU ≥ v4.2.0-rc1 offers susfs through its `KSU_SUSFS` hook mode, which requires a
  susfs kernel side using `static_key` plus a SID-based process-tracking subsystem
  (`susfs_set_ksu_sid`, `susfs_set_current_proc_umounted`, and 8 more symbols that
  ReSukiSU declares but does not define).
- No branch of [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) provides that. The
  `kernel-4.14` branch is stuck at v1.5.5 with the old boolean-hook architecture, and
  the modern `gki-android15-6.6` branch (v2.3.0) has the inline hooks but not the SID
  subsystem.
- ReSukiSU's own build guide states: *"The NonGKI branches are deprecated. If you need to
  use SUSFS, please backport it yourself."*

Making `CONFIG_KSU_SUSFS=y` work here would mean hand-porting susfs v2.3.0 from 6.6 to
4.14 **and** writing the SID subsystem from scratch. The sources for it are kept in the
tree (`fs/susfs.c`, `include/linux/susfs.h`, `include/linux/susfs_def.h`) but are
currently dead code, since they are only compiled when `CONFIG_KSU_SUSFS=y`.

---

## 📱 Device Support

| Device | Codename | Chipset | Status |
|--------|----------|---------|--------|
| Samsung Galaxy A22 4G | a22 | MT6768 | ✅ Working |
| Samsung Galaxy A22 5G | a22x | Dimensity 700 | ❌ Not Supported |

**Firmware Base:** A225MUBSCCYE1 (Android 11/One UI 3.1)

---

## 🔧 Build Requirements

```bash
# Toolchain
- GCC: aarch64-linux-android-4.9
- Clang: r383902
- Linux: x86_64

# Dependencies
- bc
- bison
- flex
- libssl-dev
- python3
- make
- git
```

---

## 📦 How to Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/A225f-T-s9.git
cd A225f-T-s9

# Set up environment
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

# Build kernel
./build_kernel.sh

# Output
# - out/arch/arm64/boot/Image
# - out/arch/arm64/boot/Image.gz
```

---

## 📥 How to Flash

### Method 1: Using Kitchen Tool (Recommended)

```bash
# Unpack stock boot.img
cd Kitchen
bash kitchen unpack boot.img

# Replace kernel
cp /path/to/built/Image workspace/kernel

# Repack
bash kitchen repack

# Flash with Odin
# - Put boot.img in AP slot
# - Put vbmeta.img in USERDATA/VBMETA slot
```

### Method 2: Using MagiskBoot

```bash
# Unpack
magiskboot unpack boot.img

# Replace kernel
magiskboot split boot.img
cp Image kernel

# Repack
magiskboot repack boot.img

# Flash
fastboot flash boot new-boot.img
```

### Odin Flash Guide

| Odin Slot | File |
|-----------|------|
| BL | BL firmware |
| AP | AP firmware (or custom boot.img) |
| CP | CP firmware |
| CSC | CSC (or HOME_CSC) |
| USERDATA | vbmeta.img (disabled) |

⚠️ **Important:** Flash **disabled vbmeta.img** to avoid bootloop or "internal problem" error!

---

## 🎯 Root Solution Setup

1. **Flash the boot image** using Odin
2. **Install the manager** from [GitHub Releases](https://github.com/ReSukiSU/ReSukiSU/releases)
3. **Open the manager** - It should show "ReSukiSU is working"
4. **Configure allowlist** - Grant root access to apps that need it
5. **Enable Zygisk** (optional) - For LSPosed and modules

To re-add or update ReSukiSU in this tree:

```bash
curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash
```

Then regenerate the config and build. `KernelSU/` is intentionally not tracked by git,
so the setup script must be re-run after a fresh clone.

---

## 🔒 Security Notes

- **AVB (Android Verified Boot):** Enabled in kernel
- **dm-verity:** Enabled in kernel
- **SELinux:** Enforcing (can be set to permissive via cmdline)
- **Root hiding:** ReSukiSU only. susfs is unavailable on this kernel, see above.

⚠️ **Warning:** This kernel modifies system behavior. Use at your own risk!

---

## 🐛 Known Issues

- [ ] "Internal problem" popup may appear (requires disabled vbmeta)
- [ ] Some banking apps may still detect root (use HideMyApplist + Shamiko)
- [ ] Google Pay may not work (use MagiskHide/Play Integrity Fix)

---

## 📝 Changelog

### v3.0.0 - ReSukiSU migration
- ✅ **ReSukiSU v4.2.0-rc3** replaces KernelSU-Next
- ✅ **Manual hook mode** configured for this non-GKI 4.14 kernel
- ✅ **Kernel hooks updated** to the ReSukiSU manual-integrate reference
  - `fs/exec.c`: `ksu_handle_execveat` + `ksu_handle_post_execveat` (drops the old
    `ksu_execveat_hook` / `ksu_handle_execveat_sucompat` boolean-hook style)
  - `fs/stat.c`: added `ksu_handle_newfstat_ret` and `ksu_handle_fstat64_ret`
  - `fs/read_write.c`: dropped the susfs-only `ksu_vfs_read_hook` hook
- ✅ **`include/generated/compile.h` shim** - ReSukiSU ≥ v4.2.0-rc1 includes this header
  unconditionally, but only kernels ≥ 4.16 generate it. The top-level `Makefile` now
  emits it with `UTS_RELEASE` and `UTS_MACHINE`.
- ⚠️ **susfs disabled** - see the section above for the upstream incompatibility.
  The susfs sources remain in the tree as dead code.
- ✅ **Full kernel build verified** (`Image`, all 6 manual hooks detected at build time)

### v2.0.0 - KPM Support Update
- ✅ **KPM Module Loader** - Kernel Package Manager support added
- ✅ **KALLSYMS_ALL Enabled** - Required for KPatch-Next and KPM modules
- ✅ **KPatch-Next Compatible** - Full kernel patching support
- ✅ **All susfs v2.0.0 features** - Fully functional
- ✅ **KernelSU-Next v3.1.0-legacy-susfs** - Latest version
- ✅ **Device Support** - All MT6768 A22 4G variants (SM-A225F/M/G/N/B)
- ✅ **Build Improvements** - Clean compilation with all features


### v1.0 - Initial Release
- ✅ KernelSU-Next v3.1.0-legacy-susfs integrated
- ✅ susfs v2.0.0 fully integrated
- ✅ All susfs features enabled
- ✅ kallsyms hiding implemented
- ✅ Module hiding implemented
- ✅ uname spoofing implemented
- ✅ Custom kernel version: `爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## 🙏 Credits & Thanks

### Original Development
- **[@physwizz](https://t.me/physwizz)** - Original kernel backporting and base development
- **ReSukiSU Team** - [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU)
- **simonpunk** - [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)

### Special Thanks
- **topjohnwu** - [Magisk](https://github.com/topjohnwu/Magisk) for magiskboot
- **tiann** - Original [KernelSU](https://github.com/tiann/KernelSU)
- **ravindu644** - [Kitchen](https://github.com/ravindu644/Kitchen) tool

### Current Maintainer
- **[@Mastermind](https://t.me/bitcockiii)** - ReSukiSU integration

---

## 📚 Sources

- **Kernel Source:** This repository
- **ReSukiSU:** https://github.com/ReSukiSU/ReSukiSU
- **ReSukiSU manual hook reference:** https://resukisu.org/guide/manual-integrate.html
- **susfs (not enabled, see above):** https://gitlab.com/simonpunk/susfs4ksu
- **Stock Firmware:** Samsung firmware repositories

---

## 📞 Support & Discussion

- **Telegram Channel:** [Your Channel Link]
- **Telegram Group:** [Your Group Link]
- **XDA Thread:** [XDA Thread Link]

---

## 📄 License

- **Kernel:** GPL-2.0
- **ReSukiSU:** GPL-3.0
- **susfs (unused sources kept in tree):** GPL-3.0

---

## ⚠️ Disclaimer

This kernel is provided "as is" without any warranty. Flashing custom kernels may void your warranty and can potentially brick your device. Use at your own risk!

The developers are not responsible for any damage to your device, data loss, or any other issues that may occur from using this kernel.

---

**Made with ❤️ by Mastermind**
