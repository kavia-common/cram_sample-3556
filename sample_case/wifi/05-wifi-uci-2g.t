# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Validate UCI wireless radio settings for 2.4GHz band (country/channel/htmode) and basic wifi-iface presence.
# Notes:
#  - Read-only: no uci set/commit/reload.
#  - Skip-safe if UCI or wireless config not present, or if no 2.4GHz radio is detectable.
#  - Best-effort across OpenWrt versions: radio sections may be wifi-device or radioX.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Skip gracefully if wireless config missing:

  $ R 'uci -q show wireless >/dev/null 2>&1 || { echo wireless-config-missing; exit 0; }'
  wireless-config-missing (glob)

Skip gracefully if DUT does not appear 2.4GHz-capable (based on iw phy):

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }; iw phy 2>/dev/null | grep -Eiq "\b(2412|2437|2462|2484)\b" || { echo "2G not supported (no 2.4GHz freqs in iw phy)"; exit 0; }'
  2G not supported (no 2.4GHz freqs in iw phy)

Show likely 2.4GHz radio blocks and validate presence of key fields (best-effort):
- country (optional but recommended)
- htmode (HT20/HT40/VHT/HE/EHT varies by platform; 2G commonly HT20/HT40/HE20)
- channel (often 1/6/11 or auto)

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -Ei "wireless\.(radio[0-9]+|@wifi-device\[N\])\.(band|hwmode|country|channel|htmode|disabled)=" | grep -Ei "(\.band='\''2g'\''|\.band='\''2\.4g'\''|\.hwmode='\''11g'\''|\.hwmode='\''11ng'\''|\.hwmode='\''11axg'\''|\.hwmode='\''11be'\''|\.channel=|\.htmode=|\.country=|\.disabled=)" | sort'
  * (glob)

Sanity: Ensure at least one wifi-iface references some device and has an SSID (uci presence only):

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -E "wireless\.@wifi-iface\[N\]\.(device|ssid|mode|encryption)=" | sort | uniq | head -n 20'
  * (glob)
