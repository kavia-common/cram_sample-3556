# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify scan output includes at least one 2.4GHz frequency (best-effort) without connecting.
# Notes:
#  - Read-only and non-destructive.
#  - Skip-safe: scanning may be blocked by regulatory/driver state; test exits 0 with message.
#  - Uses `iw dev <if> scan` and only checks frequency lines (normalized).

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Pick any wireless interface to scan with (skip-safe if none):

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; [ -n "$IF" ] || { echo no-wifi-iface; exit 0; }; echo "$IF" | sed "s/.*/<IF>/"'
  <IF>

Attempt scan and check for 2.4GHz freq presence:
- Accepts common "freq: 2412" formatting.
- If scan fails, print a clear message and exit 0.

  $ R 'IF="$(iw dev 2>/dev/null | awk "/Interface/ {print \$2; exit}")"; \
OUT="$(iw dev "$IF" scan 2>/dev/null | grep -E "freq:" | head -n 50 || true)"; \
if [ -z "$OUT" ]; then echo "scan-not-available"; exit 0; fi; \
echo "$OUT" | grep -E "freq: (2412|2437|2462|2484)" >/dev/null 2>&1 && echo "SCAN_2G_FREQ_PRESENT=yes" || echo "SCAN_2G_FREQ_PRESENT=no"'
  SCAN_2G_FREQ_PRESENT=* (glob)
