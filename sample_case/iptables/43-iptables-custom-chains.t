# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Custom chains per-zone and jump hooks (temporary)
# Notes:
#  - Skip-safe if no interfaces found. Deterministic verification and cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Detect LAN and WAN interfaces (skip-safe if none):

  $ R 'LAN_IF="$(ip -o link show 2>/dev/null | awk -F\": \" "/\\blan[1-9]\\b|\\bbr-lan\\b/{print $2; exit}")"; WAN_IF="$(ip route show default 2>/dev/null | awk "/default/ {for(i=1;i<=NF;i++){if($i==\\\"dev\\\"){print $(i+1); exit}}}")"; [ -n "$LAN_IF" ] || [ -n "$WAN_IF" ] || { echo if-missing; exit 0; }; echo OK'
  OK

Create chains and hook:

  $ R 'iptables -N CRAM_LAN 2>/dev/null || true; iptables -N CRAM_WAN 2>/dev/null || true; [ -n "$LAN_IF" ] && iptables -I INPUT 1 -i "$LAN_IF" -j CRAM_LAN || true; [ -n "$WAN_IF" ] && iptables -I INPUT 1 -i "$WAN_IF" -j CRAM_WAN || true; echo hooked'
  hooked

Verify hooks:

  $ R '[ -n "$LAN_IF" ] && iptables-save | grep -E "^-A INPUT .* -i ${LAN_IF} .* -j CRAM_LAN" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || echo no-lan-hook'
  * (glob)
  $ R '[ -n "$WAN_IF" ] && iptables-save | grep -E "^-A INPUT .* -i ${WAN_IF} .* -j CRAM_WAN" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || echo no-wan-hook'
  * (glob)

Cleanup:

  $ R '[ -n "$LAN_IF" ] && iptables -D INPUT -i "$LAN_IF" -j CRAM_LAN 2>/dev/null || true; [ -n "$WAN_IF" ] && iptables -D INPUT -i "$WAN_IF" -j CRAM_WAN 2>/dev/null || true; iptables -F CRAM_LAN 2>/dev/null || true; iptables -F CRAM_WAN 2>/dev/null || true; iptables -X CRAM_LAN 2>/dev/null || true; iptables -X CRAM_WAN 2>/dev/null || true; echo cleaned'
  cleaned
