# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Validate UCI wireless radio settings for 6GHz band (country/channel/htmode) and related Wi-Fi 6E/7 iface knobs.
# Notes:
#  - Read-only: no uci set/commit/reload.
#  - Skip-safe if UCI or wireless config not present, or if no 6GHz capability is detectable.
#  - Best-effort: 6GHz may not have explicit band fields depending on OpenWrt release/driver.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Skip gracefully if wireless config missing:

  $ R 'uci -q show wireless >/dev/null 2>&1 || { echo wireless-config-missing; exit 0; }'
  wireless-config-missing (glob)

Skip gracefully if DUT does not appear 6GHz-capable (based on iw phy):

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }; iw phy 2>/dev/null | grep -Eiq "(6 GHz|6GHz|\b5925\b|\b5955\b|\b5975\b|\b6115\b|\b6275\b|\b6535\b|\b6855\b|\b7115\b)" || { echo "6G not supported (no 6GHz band in iw phy)"; exit 0; }'
  6G not supported (no 6GHz band in iw phy)

Show likely 6GHz radio fields (best-effort, normalized indices):
- band=6g or hwmode hinting 6GHz
- country is important for 6GHz bringup

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -Ei "wireless\.(radio[0-9]+|@wifi-device\[N\])\.(band|hwmode|country|channel|htmode|disabled)=" | grep -Ei "(6g|6ghz|ax|be|eht|he|5925|psc|country|htmode|channel|disabled)" | sort'
  * (glob)

Show wifi-iface fields relevant to WPA3/SAE and 6GHz bringup (presence only):

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -Ei "wireless\.@wifi-iface\[N\]\.(ssid|device|mode|encryption|ieee80211w|sae|sae_pwe|owe|wpa_disable_eapol_key_retries|he_|eht_|mld|multi_link)" | sort | head -n 60'
  * (glob)
