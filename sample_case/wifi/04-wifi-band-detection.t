# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Detect 2.4GHz/5GHz/6GHz capability per PHY and whether any active interface is currently on those bands.
# Notes:
#  - Read-only, deterministic output normalization.
#  - Skip-safe: does not fail if a band is not supported; reports capability/no-capability.
#  - "Capability" is inferred from `iw phy` frequency listings (best-effort across iw/kernel variants).

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw is missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Report per-band capability across all PHYs (2G/5G/6G), best-effort:
- 2G: any frequency around 2412..2484
- 5G: any frequency around 5180..5900
- 6G: any frequency around 5925..7125

  $ R 'PHY="$(iw phy 2>/dev/null || true)"; \
if echo "$PHY" | grep -Eiq "\b(2412|2437|2462|2484)\b"; then echo "CAP_2G=yes"; else echo "CAP_2G=no"; fi; \
if echo "$PHY" | grep -Eiq "\b(5180|5200|5220|5240|5260|5280|5300|5320|5500|5745|5765|5785|5805|5825|5845|5865|5885)\b"; then echo "CAP_5G=yes"; else echo "CAP_5G=no"; fi; \
if echo "$PHY" | grep -Eiq "(6 GHz|6GHz|\b5925\b|\b5955\b|\b5975\b|\b6115\b|\b6275\b|\b6535\b|\b6855\b|\b7115\b)"; then echo "CAP_6G=yes"; else echo "CAP_6G=no"; fi'
  CAP_2G=* (glob)
  CAP_5G=* (glob)
  CAP_6G=* (glob)

Report whether any currently active interface is operating on each band (best-effort):
- Uses `iw dev` "channel ... (freq MHz)" lines when present.
- If no channel lines present, reports active=no for all (still deterministic).

  $ R 'iw dev 2>/dev/null | awk '\''
    BEGIN{a2=0;a5=0;a6=0}
    /channel/ && /\([0-9]+ MHz\)/ {
      if (match($0, /\(([0-9]+) MHz\)/, m)) {
        f=m[1]+0
        if (f>=2412 && f<=2484) a2=1
        else if (f>=5180 && f<5925) a5=1
        else if (f>=5925 && f<=7125) a6=1
      }
    }
    END{
      print "ACTIVE_2G=" (a2?"yes":"no")
      print "ACTIVE_5G=" (a5?"yes":"no")
      print "ACTIVE_6G=" (a6?"yes":"no")
    }'\'' | sort'
  ACTIVE_2G=* (glob)
  ACTIVE_5G=* (glob)
  ACTIVE_6G=* (glob)
