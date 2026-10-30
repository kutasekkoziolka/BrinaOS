# Budowa portu na PC — realme GT NEO 3T (RMX3371 / RE54E4L1)

Konkretna instrukcja. Wszystko na **Linuxie x86_64** (Ubuntu/Debian najprościej) —
na telefonie się nie da: brak Javy i Pythona, 2 GB wolnego RAM-u.

## 0. Czego potrzebujesz

| | |
| :--- | :--- |
| System | Linux x86_64, sudo |
| Miejsce | ~60 GB wolnego (obrazy + `super.img` + zip) |
| RAM | 8 GB+ (baksmali `framework.jar` potrafi zjeść kilka GB) |
| Baza | firmware `RMX3371` — realme UI 5.0 / Android 14, np. `RMX3371_14.0.0.1310(EX01)`, `.zip` z `payload.bin` (albo obrazy `.img`) |
| Port | ColorOS 16 / realme UI 7, `.zip` z `payload.bin` lub obrazami |
| Telefon | odblokowany bootloader (to V-AB, więc flash przez fastboot/OTA, nie TWRP) |

`.ozip` / `.ofp` **nie działają** — najpierw rozpakuj do `payload.bin`.

## 1. Zależności i repo

```bash
sudo apt update
sudo apt install -y git aria2 python3 busybox zip unzip p7zip-full \
     openjdk-21-jre zstd bc xmlstarlet android-sdk-libsparse-utils binutils

git clone https://github.com/ozyern/BrinaOS.git
cd BrinaOS
./willpower.sh
```

## 2. Folder urządzenia

```bash
mkdir -p devices/RE54E4L1/OTA/bin devices/RE54E4L1/modules

# fallback dla A-only (na tej bazie nieużywany, ale niech będzie):
cp devices/OnePlus9R/OTA/bin/updater devices/RE54E4L1/OTA/bin/
cp devices/OnePlus9R/recovery.fstab devices/RE54E4L1/
```

Do `devices/RE54E4L1/` wklej trzy pliki tekstowe z tej rozmowy: `config`,
`props.sh` i `releasetools.py`. Opcjonalnie `modules/CopySounds-from-BaseRom.sh`.

## 3. Poprawka w `getSuperSize.sh`

Wpis miał spację w środku wzorca (`RE54E4L1| RMX3371`), co psuło dopasowanie po
nazwie modelu:

```bash
sed -i 's/RE54E4L1| RMX3371/RE54E4L1 | RMX3371/' bin/getSuperSize.sh
bash bin/getSuperSize.sh RE54E4L1     # ma wypisać 11274289152
```

`config` sam wymusza `OPSM8250`, więc patch `brina.sh` (mapowanie rodzin realme)
nie jest konieczny dla tego telefonu.

## 4. Build

```bash
./brina.sh RMX3371_14.0.0.1310.zip ColorOS16.zip
```

Wynik w `out/`: pełne OTA (`ota_full-*.zip`, V-AB → `adb sideload` / OTA) albo
`super.zst` + skrypty fastboot.

## 5. Co powinno być w logu

```
RE54E4L1: family=OPSM8250 ab_update=true first_api=31 base_android=14 market='realme GT NEO 3T'
RE54E4L1: virtual A/B base (ro.build.ab_update=true) -- packing a V-AB super, A-only OTA assets unused
RE54E4L1: density my_product=480 vendor=560 (brina.sh uses my_product)
RE54E4L1: base region 'IN_all' (portrom regionmark will follow it)
```

`ab_update=false` = zła baza (stock RMX3371 jest V-AB).

## 6. Znane błędy toolkit-a na SM8250

- AOD świeci za ciemno.
- Nagrywanie wideo nie działa na serii 8 i 9R.
- Budzik głosowy, słuchawki przewodowe, ładowanie przy wyłączonym telefonie.
