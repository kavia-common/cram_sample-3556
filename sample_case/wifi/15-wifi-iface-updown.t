# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify that wireless interfaces have deterministic visibility across `iw dev` and `ip link`,
# and report per-interface operating band when possible (without toggling state).
# Notes:
#  - Read-only, deterministic normalization.
#  - Skip-safe if commands missing or if no wireless interfaces are present.
#  - Band mapping is inferred from current frequency (if any); interfaces without channel info are reported as unknown.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if iw missing:

  $ R 'command -v iw >/dev/null 2>&1 || { echo iw-missing; exit 0; }'
  iw-missing (glob)

Skip gracefully if no wireless interfaces are present:

  $ R 'iw dev 2>/dev/null | grep -q "^Interface " || { echo no-wifi-iface; exit 0; }'
  no-wifi-iface (glob)

List interfaces from iw and from ip link (normalized):
- This does not force them up/down, only shows visibility.
- Normalizes interface names to <IF>.

  $ R 'IWIFS="$(iw dev 2>/dev/null | awk "/^Interface/ {print \$2}" | sort | tr "\n" " ")"; \
IPIFS="$(ip -o link show 2>/dev/null | awk -F": " "{print \$2}" | sort | tr "\n" " ")"; \
echo "IW_IFS=${IWIFS}"; echo "IP_LINK_HAS_WIFI_IFS=$(echo "$IWIFS" | awk "{print (length(\$0)>0)?\"yes\":\"no\"}")"; \
for i in $IWIFS; do echo "$IPIFS" | grep -qw "$i" && echo "$i present-in-iplink=yes" || echo "$i present-in-iplink=no"; done \
| sed -E "s/^[^ ]+/<IF>/; s/[ ]+/ /g" | sort'
  <IF> *present-in-iplink=* (glob)

Report current band per interface from `iw dev` channel lines (best-effort):
- If no channel/freq is shown, report unknown.

  $ R 'iw dev 2>/dev/null | awk '\''
    /^Interface/ {ifc=$2; band="unknown"; freq=0}
    /channel/ && /\([0-9]+ MHz\)/ {
      if (match($0, /\(([0-9]+) MHz\)/, m)) {
        freq=m[1]+0
        if (freq>=2412 && freq<=2484) band="2G"
        else if (freq>=5180 && freq<5925) band="5G"
        else if (freq>=5925 && freq<=7125) band="6G"
      }
      print ifc " band=" band
      next
    }
    END{ }'\'' | sed -E "s/^[^ ]+/<IF>/" | sort | uniq'
  <IF> band=* (glob)
