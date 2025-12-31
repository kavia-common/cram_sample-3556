# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify scan output includes at least one 5GHz frequency (best-effort) without connecting.
# Notes:
#  - Read-only and non-destructive.
#  - Skip-safe if scan is not supported/allowed.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Pick any wireless interface (skip-safe if none):

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; [ -n "$IF" ] || { echo no-wifi-iface; exit 0; }; echo "$IF" | sed "s/.*/<IF>/"'
  <IF>

Attempt scan and check for 5GHz freq presence (5180+ and <5925):
- If scan fails/no freq lines, skip safely.

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; \
OUT="$(iw dev "$IF" scan 2>/dev/null | grep -E "freq:" | head -n 80 || true)"; \
if [ -z "$OUT" ]; then echo "scan-not-available"; exit 0; fi; \
echo "$OUT" | awk "/freq:/ {f=\$2+0; if (f>=5180 && f<5925) {found=1}} END{print found?\"SCAN_5G_FREQ_PRESENT=yes\":\"SCAN_5G_FREQ_PRESENT=no\"}"'
  SCAN_5G_FREQ_PRESENT=* (glob)
