# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Enable MASQUERADE on WAN zone and verify NAT table has MASQUERADE rule
# Notes:
#  - Follows alias/prompt style from 02-sample2.t (R alias).
#  - Deterministic, normalized outputs; graceful skip if uci missing.
#  - Restores previous state in cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Save current masquerade and enable temporary MASQUERADE:

  $ R 'WAN_IDX="$(uci -q show firewall | awk -F"[=\\[\\]]" "/^firewall.@zone\\[/{i=$3} /name=wan$/{print i}")"; [ -n "$WAN_IDX" ] || { echo wan-zone-missing; exit 0; }; WAN_MASQ_BEFORE="$(uci -q get firewall.@zone[$WAN_IDX].masq || true)"; echo "WAN_MASQ_BEFORE=${WAN_MASQ_BEFORE:-<unset>}"; uci -q set firewall.@zone[$WAN_IDX].masq=1; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2'
  WAN_MASQ_BEFORE=* (glob)

Verify MASQUERADE in POSTROUTING (normalized):

  $ R 'iptables-save -t nat 2>/dev/null | grep -E "^-A POSTROUTING" | grep -E "\\bMASQUERADE\\b" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || true'
  -A POSTROUTING * MASQUERADE* (glob)

Cleanup (restore previous state):

  $ R 'if [ -n "${WAN_MASQ_BEFORE}" ]; then uci -q set firewall.@zone[$WAN_IDX].masq="${WAN_MASQ_BEFORE}"; else uci -q del firewall.@zone[$WAN_IDX].masq || true; fi; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; echo "Restored WAN masq=${WAN_MASQ_BEFORE:-<unset>}"'
  Restored WAN masq=* (glob)
