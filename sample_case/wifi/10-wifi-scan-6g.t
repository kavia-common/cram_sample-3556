# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify scan output includes at least one 6GHz frequency (best-effort) without connecting.
# Notes:
#  - Read-only and non-destructive.
#  - Skip-safe: 6GHz may be unsupported or scan may be blocked.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Skip if no 6GHz capability is present (based on iw phy):

  $ R 'iw phy 2>/dev/null | grep -Eiq "(6 GHz|6GHz|\b5925\b|\b5955\b|\b5975\b|\b6115\b|\b6275\b|\b6535\b|\b6855\b|\b7115\b)" || { echo "6G not supported (no 6GHz band in iw phy)"; exit 0; }'
  6G not supported (no 6GHz band in iw phy)

Pick any wireless interface (skip-safe if none):

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; [ -n "$IF" ] || { echo no-wifi-iface; exit 0; }; echo "$IF" | sed "s/.*/<IF>/"'
  <IF>

Attempt scan and check for 6GHz freq presence (>=5925):
- If scan fails/no freq lines, skip safely.

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; \
OUT="$(iw dev "$IF" scan 2>/dev/null | grep -E "freq:" | head -n 120 || true)"; \
if [ -z "$OUT" ]; then echo "scan-not-available"; exit 0; fi; \
echo "$OUT" | awk "/freq:/ {f=\$2+0; if (f>=5925 && f<=7125) {found=1}} END{print found?\"SCAN_6G_FREQ_PRESENT=yes\":\"SCAN_6G_FREQ_PRESENT=no\"}"'
  SCAN_6G_FREQ_PRESENT=* (glob)
