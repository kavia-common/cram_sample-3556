# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: NAT table basics - MASQUERADE on WAN and per-LAN SNAT example (temporary)
# Notes:
#  - Skip-safe if UCI/interfaces missing. Deterministic checks. Full cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Determine wan zone index:

  $ R 'get_zone_idx() { uci -q show firewall | awk -F"[=\\[\\]]" -v Z="$1" "$0 ~ /^firewall.@zone\\[/ {idx=$3} $0 ~ (\"name=\" Z \"$\") {print idx}"; }; WAN_IDX="$(get_zone_idx wan || true)"; [ -n "$WAN_IDX" ] || { echo wan-zone-missing; exit 0; }; echo "$WAN_IDX" | sed "s/[0-9]\\+/<IDX>/"'
  <IDX>

Save current masquerade and enable temporary MASQUERADE:

  $ R 'WAN_MASQ_BEFORE="$(uci -q get firewall.@zone[$WAN_IDX].masq || true)"; echo "WAN_MASQ_BEFORE=${WAN_MASQ_BEFORE:-<unset>}"; uci -q set firewall.@zone[$WAN_IDX].masq=1; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2'
  WAN_MASQ_BEFORE=*

Verify MASQUERADE in POSTROUTING (normalized):

  $ R 'iptables-save -t nat 2>/dev/null | grep -E "^-A POSTROUTING" | grep -E "\\bMASQUERADE\\b" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || true'
  -A POSTROUTING * MASQUERADE* (glob)

Per-LAN SNAT example (optional if LAN_IF present):

  $ R 'LAN_IF="$(ip -o link show 2>/dev/null | awk -F\": \" \"/\\bbr-lan\\b|\\blan[1-4]\\b/{print $2; exit}\")"; if [ -n "$LAN_IF" ]; then iptables -t nat -I POSTROUTING 1 -o "$LAN_IF" -j SNAT --to-source 192.0.2.5 2>/dev/null || true; fi; test -n "$LAN_IF" || echo lan-if-missing'
  * (glob)

Verify SNAT line if applied:

  $ R 'test -n "${LAN_IF:-}" && iptables-save -t nat | grep -E "^-A POSTROUTING .* -o ${LAN_IF} .* -j SNAT .*to:192\\.0\\.2\\.5" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || true'
  -A POSTROUTING * -o * -j SNAT *to:192.0.2.5 (glob)

Cleanup SNAT example:

  $ R 'test -n "${LAN_IF:-}" && iptables -t nat -D POSTROUTING -o "$LAN_IF" -j SNAT --to-source 192.0.2.5 2>/dev/null || true; echo "Cleaned SNAT example on ${LAN_IF:-<none>}"'
  Cleaned SNAT example on *

Restore WAN MASQUERADE setting:

  $ R 'if [ -n "${WAN_MASQ_BEFORE}" ]; then uci -q set firewall.@zone[$WAN_IDX].masq="${WAN_MASQ_BEFORE}"; else uci -q del firewall.@zone[$WAN_IDX].masq || true; fi; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; echo "Restored WAN masq=${WAN_MASQ_BEFORE:-<unset>}"'
  Restored WAN masq=*
