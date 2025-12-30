# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: QoS/marking in mangle table per-interface (temporary)
# Notes:
#  - Skip-safe if LAN interface missing. Deterministic verification.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Detect LAN interface (skip-safe):

  $ R 'LAN_IF="$(ip -o link show 2>/dev/null | awk -F\": \" \"/\\blan[1-9]\\b|\\bbr-lan\\b/{print $2; exit}\")"; [ -n \"$LAN_IF\" ] || { echo lan-if-missing; exit 0; }; echo \"$LAN_IF\" | sed \"s/.*/<LAN>/\"'
  <LAN>

Insert mangle MARK and verify:

  $ R 'FW_MARK="0x3c01"; iptables -t mangle -I PREROUTING 1 -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-mark ${FW_MARK}; iptables-save -t mangle | grep -E "^-A PREROUTING .* -i ${LAN_IF} .* -p tcp .* --dport 60000 .* -j MARK .* (set-xmark ${FW_MARK}/0xffffffff|set-mark ${FW_MARK})" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A PREROUTING * -i * -p tcp * --dport 60000 * -j MARK * (glob)

Cleanup:

  $ R 'iptables -t mangle -D PREROUTING -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-mark ${FW_MARK} 2>/devnull || true; iptables -t mangle -D PREROUTING -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-xmark ${FW_MARK}/0xffffffff 2>/dev/null || true; echo "Cleaned mangle mark on ${LAN_IF}"'
  Cleaned mangle mark on * (glob)
