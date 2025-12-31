# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Sanity-check UCI wireless config for 6GHz-related settings on OpenWrt (QCA DUT).
# Notes:
#  - This test is read-only (no uci set/commit).
#  - 6GHz can be represented differently depending on OpenWrt release/driver:
#      * radio band might be "6g" or "6GHz" or implicit via hwmode
#      * country code/regdomain impacts 6GHz operation
#      * hostapd "op_class"/"he"/"eht" options may appear
#  - Therefore checks are best-effort and skip-safe.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci is missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Skip gracefully if wireless config is missing:

  $ R 'uci -q show wireless >/dev/null 2>&1 || { echo wireless-config-missing; exit 0; }'
  wireless-config-missing (glob)

Show any likely 6GHz-related radio fields (best-effort, normalized indices):

  $ R "uci show wireless 2>/dev/null | sed 's/@[0-9]\\+/@N/g' | grep -Ei 'wireless\\.radio[0-9]+\\.(band|hwmode|country|channel|disabled|htmode)|wireless\\.@wifi-device\\[N\\]\\.(band|hwmode|country|channel|disabled|htmode)' | sort || true"
  * (glob)

Show any likely 6GHz / Wi‑Fi 6E feature flags in wifi-iface blocks (best-effort):

  $ R "uci show wireless 2>/dev/null | sed 's/@[0-9]\\+/@N/g' | grep -Ei 'wireless\\.@wifi-iface\\[N\\]\\.(ssid|device|mode|encryption|ieee80211w|wpa_disable_eapol_key_retries|he_|eht_|sae|sae_pwe|owe|mld|multi_link)' | sort | head -n 50 || true"
  * (glob)
