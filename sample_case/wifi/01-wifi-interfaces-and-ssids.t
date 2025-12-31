# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Enumerate Wi-Fi interfaces and beaconing SSIDs on DUT (read-only).
# Notes:
#  - Normalizes whitespace and ordering for deterministic output.
#  - Works across QCA variants (ath11k/ath12k) where interface names differ.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check iw interfaces and SSIDs (normalized, sorted):

  $ R "iw dev 2>/dev/null | grep -E 'Interface|ssid' | tr -d '\t' | sed 's/[ ]\\+/ /g' | sort"
  Interface * (glob)
  ssid * (glob)
