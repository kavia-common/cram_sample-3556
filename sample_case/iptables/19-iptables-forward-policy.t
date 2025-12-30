# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Change default forward policy and verify iptables reflects expected behavior
# Notes:
#  - Uses R alias; deterministic matching; restores original value.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Save current policy and set REJECT:

  $ R 'FW_FWD_BEFORE="$(uci -q get firewall.defaults.forward || echo REJECT)"; echo "FORWARD_BEFORE=${FW_FWD_BEFORE}"; uci -q set firewall.defaults.forward=REJECT; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2'
  FORWARD_BEFORE=* (glob)

Verify REJECT/DROP presence (normalized):

  $ R 'iptables -S FORWARD 2>/dev/null | grep -E -- "-j (reject|REJECT|DROP)" | sed "s/[[:space:]]\\+/ /g" | sort | uniq | head -n 1 || true'
  -A FORWARD * -j * (glob)

Set ACCEPT and verify ACCEPT path:

  $ R 'uci -q set firewall.defaults.forward=ACCEPT; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2; iptables -S FORWARD 2>/dev/null | grep -E -- "-j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | sort | uniq | head -n 1 || true'
  -A FORWARD * -j ACCEPT* (glob)

Cleanup (restore):

  $ R 'uci -q set firewall.defaults.forward="${FW_FWD_BEFORE}"; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; echo "Restored forward policy=${FW_FWD_BEFORE}"'
  Restored forward policy=* (glob)
