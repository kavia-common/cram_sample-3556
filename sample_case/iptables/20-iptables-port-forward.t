# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Configure DNAT port forwarding via UCI and verify via iptables (temporary)
# Notes:
#  - Uses R alias, normalized outputs, full cleanup; skip-safe if uci missing.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if uci missing:

  $ R 'command -v uci >/dev/null 2>&1 || { echo uci-missing; exit 0; }'
  uci-missing (glob)

Parameters (overridable):

  $ R 'LAN_HOST="${LAN_HOST:-192.168.1.100}"; WAN_PORT="${WAN_PORT:-8080}"; LAN_PORT="${LAN_PORT:-80}"; echo "Using LAN_HOST=${LAN_HOST} WAN_PORT=${WAN_PORT} LAN_PORT=${LAN_PORT}"'
  Using LAN_HOST=* WAN_PORT=* LAN_PORT=* (glob)

Create redirect (temporary):

  $ R 'RULE_NAME="cram_dnat_test_rule_$$"; uci -q add firewall redirect >/dev/null; IDX="$(uci -q show firewall | awk -F\"[=\\[\\]]\" \"/^firewall.@redirect\\[/ {i=$3} END{print i}\")"; uci -q set firewall.@redirect[$IDX].name="${RULE_NAME}"; uci -q set firewall.@redirect[$IDX].src=wan; uci -q set firewall.@redirect[$IDX].src_dport="${WAN_PORT}"; uci -q set firewall.@redirect[$IDX].dest=lan; uci -q set firewall.@redirect[$IDX].dest_ip="${LAN_HOST}"; uci -q set firewall.@redirect[$IDX].dest_port="${LAN_PORT}"; uci -q set firewall.@redirect[$IDX].proto=tcp; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2; echo created'
  created

Verify presence in nat PREROUTING (normalized):

  $ R 'iptables-save -t nat | grep -E "^-A PREROUTING .* -p tcp .* --dport ${WAN_PORT} .* -j DNAT .*to:${LAN_HOST}(:${LAN_PORT})?" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A PREROUTING * -p tcp * --dport * -j DNAT *to:* (glob)

Cleanup:

  $ R 'for i in $(uci -q show firewall | awk -F\"[=\\[\\]]\" \"/^firewall.@redirect\\[/ {print $3}\"); do nm=\"$(uci -q get firewall.@redirect[$i].name 2>/dev/null || true)\"; [ \"$nm\" = \"${RULE_NAME}\" ] && uci -q delete firewall.@redirect[$i] || true; done; uci -q commit firewall; /etc/init.d/firewall reload >/dev/null 2>&1 || true; echo "Cleaned redirect ${RULE_NAME}"'
  Cleaned redirect * (glob)
