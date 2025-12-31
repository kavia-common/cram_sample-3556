# Wi-Fi test cases (Cram) - OpenWrt (QCA DUT)

This folder contains Wi-Fi related Cram test cases executed via:
- `sample_cram/cram.sh` (sets `CRAM_REMOTE_COMMAND="ssh root@<DUT_LAN_IP>"`)
- `python3 -m cram --verbose ./sample_case/`

## Conventions
All `.t` tests follow the conventions shown in `sample_case/02-sample2.t`:
- Create `R` alias from `CRAM_REMOTE_COMMAND`
- Use deterministic commands and normalize outputs with `sed`, `tr`, `sort`, `uniq`
- Prefer glob / regex expectations where output is platform-dependent

## 6GHz / Wi‑Fi 6E considerations (QCA + OpenWrt)
6GHz radios/interfaces may not exist depending on:
- Regulatory domain (country code), AFC/PSD restrictions, driver support
- Hardware SKU and image features (hostapd, wpad, ath11k/ath12k)
- Whether 6GHz is enabled in UCI wireless config

Therefore, tests in this folder:
- Detect whether any 6GHz-capable PHY is present (`iw phy ... Band 4/6 GHz`)
- Detect whether any 6GHz beaconing interface is present (`iw dev ... freq 59xx/6xxx`)
- Exit successfully with a clear message if 6GHz is not available (skip-safe behavior)

## Files
- `01-wifi-interfaces-and-ssids.t`: list interfaces + SSIDs (stable formatting)
- `02-wifi-6g-detection.t`: detect 6GHz PHY and 6GHz beaconing interface presence
- `03-wifi-6g-uci-config-sanity.t`: sanity-check UCI wireless config for 6GHz-related knobs (best-effort)
