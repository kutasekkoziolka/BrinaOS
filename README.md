<div align="center">

# 💋 ColorOS Porting Project ✨

*That's that me espresso... but for your phone.* ☕

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-pink.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-ff69b4.svg?style=for-the-badge)](https://github.com/ozyern/coloros_port/graphs/commit-activity)

A *Short n' Sweet* toolkit for porting ColorOS and Realme UI to Snapdragon 865, 870, and 888 series devices. 

> *Please Please Please* read the docs before starting! Don't bring me to tears when your phone won't boot. 🥺

<br>
</div>

---

## ☕ Getting Started

*Skip the small talk. Here's the whole thing.* 💅

```bash
# 1. Pour the willpower (installs every dependency — needs sudo on Linux)
./willpower.sh

# 2. Espresso in, ColorOS out
./brina.sh [--Brina] <BASEROM.zip> <PORTROM.zip> [PORTROM2.zip] [PARTITIONS]
```

Your flashable zip lands in `out/`. That's that me espresso. ☕

> 🎀 **`--Brina`** puts on the full BrinaOS look — wordmark, OTA card, setup wizard. Leave it off and you get a clean port with the ROM's own branding. *Your call, babe.*

| 🎀 Script | 💋 What it does |
| :--- | :--- |
| `brina.sh` | The main event. Does the actual porting, start to finish. |
| `caffeine.sh` | The helper library — logging, patching, all the little functions that keep `brina.sh` awake. Sourced automatically. |
| `willpower.sh` | One-time dependency setup. Run it before anything else. |

> Both local files and download links work as arguments — hand it a URL and it'll fetch the ROM itself. *No nonsense.* ✨

---

## 📱 Supported Hardware

*Because we love a good match. Is it that sweet? I guess so.* 💅

| 🫀 Chipset | 📱 Verified Devices |
| :--- | :--- |
| **Snapdragon 865/870** | OnePlus 8 Series, OnePlus 9R, OPPO Find X3 |
| **Snapdragon 888** | OnePlus 9 Series (Tested on 9 Pro), OPPO Find X3 Pro |

---

## 🔍 Tested ROMs

*We’ve got the receipts. No nonsense here.* 📝

### 🏠 Base Firmware (Host)
* **OnePlus 8 / 8T / 8 Pro:** `KB2003_14.0.0.600`, `IN2013_13.1.190`, `IN2023_13.1.0.190`
* **OnePlus 9 Pro:** `LE2123_14.0.0.1902`

### 🎯 Target Port ROMs
* **ColorOS 16:** OnePlus 15T (`16.0.5.703`), Find X9 Ultra (`16.0.5.702`)
* **OxygenOS 16:** OnePlus 15 (`16.0.7.201`)
* **Realme UI 7:** Realme GT 8 Pro (`16.0.5.704`)

---

## 🍒 Android 17 — *Bed Chem, but Make It Boot*

*An Android 11 vendor and an Android 17 system walk into a bar...* 🍸

Android 17 port ROMs on SM8250 / SM8350 vendors are **experimental**. No receipts yet — nobody has posted a tested build. When `brina.sh` sees an Android 17 port ROM, it patches in these fixes on its own:

| 💋 Fix | ☕ Why it matters |
| :--- | :--- |
| **SELinux 30.0 mapping** | Old vendor policy and the new system can talk again. Without it, first-stage init gives up. |
| **ueventd bridge** | Android 17 looks for `/vendor/etc/ueventd.rc`; old vendors keep it at `/vendor/ueventd.rc`. Now they meet in the middle. |
| **Vendor overlay & `/dev/ion` labels** | Re-applied right before the images are packed, so enforcing mode doesn't get its heart broken. |
| **qspm `renameat2`** | No more `SIGSYS` heartbreak for `qspmhal`. |
| **Wi-Fi RRO** | Fixes the radioStats crash. Wi-Fi stays short n' sweet. |
| **OMAPI / VINTF, NFC, AudioEffectCenter** | Secure element, NFC defaults and the audio effects app all show up for work. |
| **Perf HAL & display panel sepolicy** | Gated to SM8250 / SM8350, so nobody else gets fixes they don't need. |
| **HIDL IMS** *(optional)* | Drop `ims-hidl-android17.apk` into `devices/common/` and VoLTE gets a HIDL-friendly IMS. No APK, no change. |

> 🪶 Got a different vendor ABI? Point `PORT_SELINUX_MAP_SOURCE` at your own mapping folder. **Never** rename an Android 17 `31.0.cil` to `30.0.cil` — that's not sweet, that's a bootloop.

---

## 🪶 Feather Engine

*"I feel so much lighter"* — and so does every frame.

SM8250 and SM8350 ports get **Feather** automatically. It tunes SurfaceFlinger, the Adreno GPU, the scheduler, the perf HAL and ART for daily use and gaming. App compiling uses every core, background dexopt stays on the little cluster so it never steals frames, and SystemUI is fully precompiled so the shade and recents stay buttery.

---

## 🔒 Safer Flashing

*Please, please, please don't flash the wrong zip.* 🥺

- **Recovery zip:** before it writes anything, it checks the device and project code, that the package isn't damaged, that every required image and partition is there, and your RAM type (DDR4 / DDR5) so you get the right XBL.
- **Fastboot scripts:** they stop on a product mismatch, a missing image, or any flash that fails — no half-flashed phones.

---

## 🛠 Feature Status

*What's working like a dream, and what's... well, a little bit of a mess.* 🪶

### ✨ Working Perfectly
- **Security:** Face Unlock & Fingerprint (Biometrics) 💋
- **Connectivity:** NFC & Network 📶
- **Hardware:** Camera & Automatic Brightness 📸

### 🚩 Known Bugs
*Don't say I didn't warn you...*

- 🔅 **AOD:** Display is too dim on SM8250 devices.
- 🎥 **Multimedia:** Video recording is currently broken on 8 Series and 9R.
- 🔌 **Audio/Power:** Voice triggers, wired earphones, and power-off charging are taking a sick day.
- 🍒 **Android 17:** Experimental and untested on real hardware. Expect a little nonsense.

---

<div align="center">

**⚠️ Disclaimer:** Porting ROMs carries a risk of bricking your device. Always backup your data before proceeding. *Taste* the danger, but stay safe! 🔪🎀

</div>
