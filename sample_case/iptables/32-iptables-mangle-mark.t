# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Insert and verify a MARK rule in mangle PREROUTING (temporary)
# Notes:
#  - Non-destructive; rule removed in cleanup. Deterministic verification.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Insert MARK rule with unique fwmark value:

  $ R 'FW_MARK="0x1a2b"; iptables -t mangle -I PREROUTING 1 -p tcp --dport 65520 -j MARK --set-mark ${FW_MARK} 2>/dev/null || true; echo added'
  added

Verify rule presence (normalized):

  $ R 'FW_MARK="${FW_MARK:-0x1a2b}"; iptables -t mangle -S PREROUTING 2>/dev/null | grep -E -- "-p tcp .* --dport 65520 .* -j MARK .* (--set-xmark ${FW_MARK}/0xffffffff|--set-mark ${FW_MARK})" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A PREROUTING * -p tcp * --dport 65520 * -j MARK * (glob)

Cleanup:

  $ R 'FW_MARK="${FW_MARK:-0x1a2b}"; iptables -t mangle -D PREROUTING -p tcp --dport 65520 -j MARK --set-mark ${FW_MARK} 2>/dev/null || true; iptables -t mangle -D PREROUTING -p tcp --dport 65520 -j MARK --set-xmark ${FW_MARK}/0xffffffff 2>/dev/null || true; echo cleaned'
  cleaned
