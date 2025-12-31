# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Read back Tx power information (best-effort) for each active interface using `iw dev info`.
# Notes:
#  - Read-only and non-destructive.
#  - Skip-safe if iw missing or no wireless interfaces.
#  - Normalizes interface names to <IF> and numeric fields to stable tokens where feasible.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Skip gracefully if no wireless interfaces are present:

  $ R 'iw dev 2>/dev/null | grep -q "^Interface " || { echo no-wifi-iface; exit 0; }'
  no-wifi-iface (glob)

Show per-interface txpower lines (best-effort):
- `iw dev <if> info` often includes "txpower X.XX dBm"
- Some drivers may omit; we still output a marker per interface.

  $ R 'for IF in $(iw dev 2>/dev/null | awk "/^Interface/ {print \$2}"); do \
INFO="$(iw dev "$IF" info 2>/dev/null || true)"; \
TP="$(echo "$INFO" | grep -E "txpower" | head -n 1 || true)"; \
if [ -n "$TP" ]; then echo "$IF $TP"; else echo "$IF txpower:unknown"; fi; \
done | sed -E "s/^[^ ]+/<IF>/; s/txpower[ ]+[0-9]+\.[0-9]+ dBm/txpower X.XX dBm/; s/txpower[ ]+[0-9]+ dBm/txpower XX dBm/; s/[ ]+/ /g" | sort'
  <IF> txpower* (glob)
