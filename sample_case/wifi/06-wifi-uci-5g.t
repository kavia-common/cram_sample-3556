# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Validate UCI wireless radio settings for 5GHz band (country/channel/htmode) and basic wifi-iface presence.
# Notes:
#  - Read-only: no uci set/commit/reload.
#  - Skip-safe if UCI or wireless config not present, or if no 5GHz radio is detectable.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Skip gracefully if wireless config missing:

  $ R 'uci -q show wireless >/dev/null 2>&1 || { echo wireless-config-missing; exit 0; }'
  wireless-config-missing (glob)

Skip gracefully if DUT does not appear 5GHz-capable (based on iw phy):

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }; iw phy 2>/dev/null | grep -Eiq "\b(5180|5200|5220|5240|5500|5745|5805)\b" || { echo "5G not supported (no 5GHz freqs in iw phy)"; exit 0; }'
  5G not supported (no 5GHz freqs in iw phy)

Show likely 5GHz radio blocks and key fields (best-effort, normalized indices):
- htmode should often be VHT80/HE80/EHT80 (device-dependent)
- channel may be DFS or non-DFS; this test does not enforce a specific channel

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -Ei "wireless\.(radio[0-9]+|@wifi-device\[N\])\.(band|hwmode|country|channel|htmode|disabled)=" | grep -Ei "(\.band='\''5g'\''|\.band='\''5\.0g'\''|\.hwmode='\''11a'\''|\.hwmode='\''11na'\''|\.hwmode='\''11ac'\''|\.hwmode='\''11axa'\''|\.channel=|\.htmode=|\.country=|\.disabled=)" | sort'
  * (glob)

Sanity: Ensure wifi-iface blocks exist (uci presence only, no association needed):

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -E "wireless\.@wifi-iface\[N\]\.(device|ssid|mode|encryption)=" | sort | uniq | head -n 20'
  * (glob)
