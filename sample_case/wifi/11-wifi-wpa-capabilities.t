# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Check WPA2/WPA3-related capabilities without connecting:
#  - `iw phy`/`iw list` cipher suites and AKM suites (best-effort)
#  - presence of hostapd/wpad binary and basic feature hints
# Notes:
#  - Read-only, deterministic (normalized), skip-safe if tools unavailable.
#  - Does not require any specific SSID or association.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Check cipher/AKM hints from iw phy output (best-effort, normalized):
- Look for CCMP/TKIP/GCMP (WPA2/WPA3 common)
- Look for SAE / 802.1X / PSK (AKM hints vary)

  $ R 'iw phy 2>/dev/null | tr -d "\t" | sed "s/[ ]\+/ /g" | grep -E "Cipher|CCMP|TKIP|GCMP|SAE|PSK|802\.1X|WPA" | head -n 40 || echo iw-no-wpa-hints'
  * (glob)

Check wpad/hostapd presence and print version line (best-effort):
- OpenWrt typically uses /usr/sbin/hostapd or hostapd.* variants, and wpad
- If not present, skip safely.

  $ R 'HP="$(command -v hostapd 2>/dev/null || true)"; WP="$(command -v wpad 2>/dev/null || true)"; \
if [ -n "$HP" ] || [ -n "$WP" ]; then echo "APD_PRESENT=yes"; else echo "APD_PRESENT=no"; exit 0; fi'
  APD_PRESENT=* (glob)

Show hostapd/wpad help/version lines (normalized, best-effort):
- We do not assert a specific build; just surface that it exists.

  $ R '({ hostapd -v 2>/dev/null || true; wpad -v 2>/dev/null || true; } | head -n 3) || true'
  * (glob)

Check for common WPA3/SAE keywords in hostapd help output (best-effort):
- Some builds print compile options; others do not. This is informational and deterministic.

  $ R 'if hostapd -h 2>/dev/null | grep -Eiq "(sae|wpa3|owe)"; then echo "HOSTAPD_HINTS_WPA3=yes"; else echo "HOSTAPD_HINTS_WPA3=no"; fi'
  HOSTAPD_HINTS_WPA3=* (glob)
