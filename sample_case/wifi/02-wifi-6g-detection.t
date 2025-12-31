# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Detect 6GHz (Wi‑Fi 6E) capability and any active 6GHz interface on a QCA OpenWrt DUT.
# Notes:
#  - 6GHz availability depends on regulatory domain / image / hardware.
#  - This test is skip-safe: it exits 0 if no 6GHz capability is present.
#  - Deterministic checks; output normalized for Cram expectations.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Detect if any PHY advertises a 6GHz band (iw phy output varies by kernel/iw; match multiple patterns):

  $ R 'if iw phy 2>/dev/null | grep -Eiq "(Band [0-9]+:.*(5925|6[0-9]{3})|6 GHz|6GHz)"; then echo "6G_CAPABLE=yes"; else echo "6G_CAPABLE=no"; fi'
  6G_CAPABLE=* (glob)

If not 6G capable, skip remaining checks gracefully:

  $ R 'iw phy 2>/dev/null | grep -Eiq "(Band [0-9]+:.*(5925|6[0-9]{3})|6 GHz|6GHz)" || { echo "6G not supported (no 6GHz band in iw phy)"; exit 0; }'
  6G not supported (no 6GHz band in iw phy)

Check whether any interface is currently operating on a 6GHz frequency (best-effort):
- `iw dev` -> "channel ... (freq MHz)" lines
- Consider 5925..7125 MHz as the 6GHz band for detection purposes

  $ R 'iw dev 2>/dev/null | awk "BEGIN{found=0} /channel/ && /\\(.*MHz\\)/ { if (match($0, /\\(([0-9]+) MHz\\)/, a)) { f=a[1]; if (f>=5925 && f<=7125) found=1 } } END{ if(found) print \"6G_ACTIVE_IF=yes\"; else print \"6G_ACTIVE_IF=no\" }"'
  6G_ACTIVE_IF=* (glob)
