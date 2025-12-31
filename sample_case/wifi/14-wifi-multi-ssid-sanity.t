# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Sanity-check that multiple SSIDs/interfaces are configured (UCI presence only).
# Notes:
#  - Read-only, deterministic, skip-safe.
#  - Does not require that SSIDs are beaconing; only checks config presence.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Skip gracefully if wireless config missing:

  $ R 'uci -q show wireless >/dev/null 2>&1 || { echo wireless-config-missing; exit 0; }'
  wireless-config-missing (glob)

Count wifi-iface sections and print count (deterministic):

  $ R 'CNT="$(uci show wireless 2>/dev/null | grep -E "wireless\.@wifi-iface\[[0-9]+\]=wifi-iface" | wc -l | tr -d " ")"; echo "WIFI_IFACE_SECTIONS=${CNT}"'
  WIFI_IFACE_SECTIONS=* (glob)

List SSIDs (normalized indices, stable sort):
- Normalization replaces @<index> to @N.

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -E "wireless\.@wifi-iface\[N\]\.ssid=" | sort'
  *ssid* (glob)

List iface encryption modes (presence only):

  $ R 'uci show wireless 2>/dev/null | sed "s/@[0-9]\+/@N/g" | grep -E "wireless\.@wifi-iface\[N\]\.(encryption|ieee80211w|sae|owe)=" | sort | head -n 50 || true'
  * (glob)
