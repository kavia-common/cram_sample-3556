# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Awareness checks for:
#  - 5GHz DFS channels (presence in `iw phy` frequency list)
#  - 6GHz PSC channels (presence of known PSC center freqs/channels in `iw phy`)
# Notes:
#  - Read-only and skip-safe: prints informative markers and exits 0.
#  - Does not require setting a DFS channel or enabling 6GHz.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

DFS awareness (5GHz):
- DFS channels often include 5260..5700 ranges; `iw phy` may mark as (DFS) or NO-IR.
- We only check if those freqs appear at all.

  $ R 'PHY="$(iw phy 2>/dev/null || true)"; \
if echo "$PHY" | grep -Eiq "\b(5260|5280|5300|5320|5500|5520|5540|5560|5580|5600|5620|5640|5660|5680|5700)\b"; then echo "DFS_FREQS_LISTED=yes"; else echo "DFS_FREQS_LISTED=no"; fi'
  DFS_FREQS_LISTED=* (glob)

6GHz PSC awareness:
- PSC channels (20 MHz) are channels 5, 21, 37, 53, 69, 85, 101, 117, 133, 149, 165, 181, 197, 213 (varies by regdom).
- Frequencies for PSC centers (MHz) include: 5975, 6055, 6135, 6215, 6295, 6375, 6455, 6535, 6615, 6695, 6775, 6855, 6935, 7015.
- If 6GHz is not supported, skip gracefully.

  $ R 'PHY="$(iw phy 2>/dev/null || true)"; echo "$PHY" | grep -Eiq "(6 GHz|6GHz|\b5925\b|\b5975\b)" || { echo "PSC_6G: not-applicable (no 6GHz)"; exit 0; }; \
if echo "$PHY" | grep -Eiq "\b(5975|6055|6135|6215|6295|6375|6455|6535|6615|6695|6775|6855|6935|7015)\b"; then echo "PSC_FREQS_LISTED=yes"; else echo "PSC_FREQS_LISTED=no"; fi'
  PSC_* (glob)
