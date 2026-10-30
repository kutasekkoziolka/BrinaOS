# realme GT NEO 3T — `RE54E4L1` / `RMX3371`

Device config for the BrinaOS (ColorOS Porting Project) toolkit.

| | |
| :--- | :--- |
| Model | `RMX3371` (realme GT NEO 3T) |
| `ro.product.device` | `RE54E4L1` ← **folder name must match this**, not the model |
| Platform | `kona` — SM8250-AC / Snapdragon 870 |
| Baza | realme UI 5.0 / Android 14, `RMX3371_14.0.0.1310(EX01)`, region IN (gdpr) |
| Docelowy port | ColorOS 16 / realme UI 7 (pakiet z `payload.bin` lub obrazami) |
| Partycje | **virtual A/B** + dynamiczne (super), super = `11274289152` B (zmierzony) |
| Rodzina | `OPSM8250` (baza już to podaje) |

---

## Co jest w tym folderze

| Plik | Do czego |
| :--- | :--- |
| `props.sh` | `experimental=0`. Konwencja toolkit-a; `config` sourcinguje ten plik, bo sam `brina.sh` go nie czyta. |
| `config` | Wczytywany przez `brina.sh` po odczytaniu propów bazy i portu. Wymusza `base_device_family=OPSM8250` (siatka bezpieczeństwa), pilnuje, czy baza jest V-AB, wypisuje gęstość, region, rozmiar super i listę partycji logicznych. |
| `recovery.fstab` | **Nie jest używany** na tej bazie (V-AB → `brina.sh` nie kopiuje go). Zostawiony jako fallback dla bazy A-only. |
| `releasetools.py` | Hooki `ota_from_target_files` — też tylko dla ścieżki A-only, więc na RMX3371 nieużywane. Wersja minimalna: bez asercji `ro.separate.soft` (szablony OnePlus abortowałyby flash) i bez wpisywania obrazów firmware, których w tej bazie nie ma. |
| `OTA/bin/updater` | Binarka `updater` do pakietu A-only — na V-AB nieużywana. |
| `modules/CopySounds-from-BaseRom.sh` | Generyczny moduł: dociąga dźwięki systemowe z bazy, jeśli port ma puste `media`. |
| `overlay/` | (jeszcze nie ma) Wszystko, co tu wrzucisz, jest kopiowane **na** drzewo portu. Tu trafiają nadpisane pliki: `vendor/build.prop`, `vendor/etc/fstab.qcom`, skrypty init, RRO. |
| `INSTRUKCJA-PC.md` | Budowa na komputerze, krok po kroku. |

---

## Co potwierdzone z bazy `RMX3371_14.0.0.1310(EX01)`

| Prop | Wartość | Znaczenie |
| :--- | :--- | :--- |
| `ro.product.device` | `RE54E4L1` | nazwa folderu |
| `ro.product.model` | `RMX3371` | model |
| `ro.vendor.oplus.market.name` | `realme GT NEO 3T` | nazwa marketingowa |
| `ro.board.platform` | `kona` | SM8250-AC / 870 |
| `ro.build.device_family` | `OPSM8250` | już poprawna, wszystkie fixy SM8250 zadziałają |
| `ro.build.ab_update` | `true` | **virtual A/B**, nie A-only |
| `ro.virtual_ab.enabled` | `true` | potwierdza V-AB |
| `vendor/etc/fstab.qcom` | `slotselect` + `logical` | potwierdza V-AB |
| `ro.product.first_api_level` | `31` | port dostaje 31 |
| `ro.sf.lcd_density` | `480` (my_product) / `560` (vendor) | brina.sh bierze 480 |
| `ro.oplus.image.my_region.type` | `IN_all` | region IN, port dostanie ten regionmark |
| `ro.separate.soft` | `21732` | kod projektu realme |
| `ro.build.version.oplusrom` | `V14.0.0` | realme UI 5.0 |

Partycje logiczne w bazie: `system system_ext product vendor odm my_product my_engineering my_company my_carrier my_region my_heytap my_stock my_preload my_bigball my_manifest` (bez `system_dlkm` / `vendor_dlkm`).

**Wszystko potwierdzone:** rozmiar super zmierzony na telefonie
(`blockdev --getsize64 /dev/block/*/super` → `11274289152`, czyli dokładnie tyle, ile
podaje tabela `bin/getSuperSize.sh`). `config` tylko to odnotowuje w
`device_super_size` — `brina.sh` tej zmiennej nie czyta.

---

### Zmiany poza folderem urządzenia

Na **stockowym** `ozyern/BrinaOS` nie trzeba nic zmieniać w `brina.sh`:

- `bin/getSuperSize.sh` ma wpis `RE54E4L1| RMX3371` (spacja przed modelem). To psuje
  dopasowanie tylko po nazwie modelu — po `RE54E4L1` (a tego używa `brina.sh`)
  działa poprawnie i daje `11274289152`. Workflow i tak to poprawia.
- Rodzina urządzenia: baza sama podaje `ro.build.device_family=OPSM8250`, więc
  mapowanie `kona → OPSM8250` nie jest potrzebne.
- Gęstość: `ro.sf.lcd_density=480` jest w `my_product`, czyli tam, gdzie
  `brina.sh` jej szuka — fallback nie jest potrzebny.

Jedyne, co dokłada workflow, to dwa haki `rm` wstrzykiwane do `brina.sh`
w locie (`CI_FREE_SPACE=true`), żeby zmieścić build na darmowym runnerze:

1. po rozpakowaniu obu ROM-ów kasuje zipy i cache `build/<version_name>/*.img`,
2. w pętli pakowania kasuje drzewo partycji zaraz po zbudowaniu z niego `.img`
   (poza `my_manifest`, z którego chwilę później czytany jest `rom_version`,
   i tylko na V-AB, bo ścieżka A-only czyta te drzewa ponownie).

Workflow sprawdza, czy oba miejsca nadal istnieją — jak upstream je zmieni,
build pada od razu z komunikatem, zamiast wysypać się na braku miejsca.

---

## Jak zbudować

```bash
./willpower.sh                                   # zależności (apt/pacman/brew)
./brina.sh RMX3371_14.0.0.1310.zip ColorOS16.zip # wynik w out/
```

Przydatne przełączniki:

```bash
./brina.sh --Brina base.zip port.zip                 # branding BrinaOS
./brina.sh --kernel kernel.zip base.zip port.zip     # własne boot.img (AnyKernel3)
```

Baza musi być pakietem z `payload.bin`, plikami `*.br` albo obrazami `.img`.
`.ozip` / `.ofp` **nie są obsługiwane** — najpierw rozpakuj do `payload.bin`.

Na komputerze z ~50 GB wolnego miejsca nie trzeba nic więcej. Na darmowym
runnerze GitHub Actions workflow dokłada dwa haki `rm` (patrz „Zmiany poza
folderem urządzenia”), bo 6,15 + 9,46 GB samych zipów plus rozpakowane drzewa i
`super.img` nie mieszczą się w 14 GB.

## Co powinno pojawić się w logu

```
RE54E4L1: family=OPSM8250 ab_update=true first_api=31 base_android=14 market='realme GT NEO 3T'
RE54E4L1: virtual A/B base (ro.build.ab_update=true) -- packing a V-AB super, A-only OTA assets unused
RE54E4L1: density my_product=480 vendor=560 (brina.sh uses my_product)
RE54E4L1: base region 'IN_all' (portrom regionmark will follow it)
RE54E4L1: super=11274289152 B, logical partitions in base: my_bigball my_carrier ...
```

Jeśli zamiast tego pojawi się `base reports ro.build.ab_update=false` — to nie jest firmware RMX3371.

## Czego tu celowo nie ma

- **Moduły kamery** (`Camera-*-fixes-*`) — to poprawki do aparatu z ODM OnePlusa; baza realme ma własny ODM i `OplusCamera`, a moduły nadpisują całe drzewa partycji.
- **`Realme-gesture`** (`modules/rui/`) — deskryptor istnieje w drzewach OnePlus9/9Pro, ale modułu nie ma już w `blahajcoding/coloros_port-modules` (byłby 404).
- **`overlay/`** z propami — vendor i odm i tak idą z bazy, więc nadpisywanie ich bez powodu tylko psuje.

## Znane błędy toolkit-a na SM8250

- AOD świeci za ciemno.
- Nagrywanie wideo nie działa na serii 8 i 9R.
- Budzik głosowy, słuchawki przewodowe, ładowanie przy wyłączonym telefonie.
