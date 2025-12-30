# Test: Configure DNAT port forwarding from WAN to LAN host and verify nat PREROUTING rule presence

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Environment variables (adjust to match your LAN host and port)
$ LAN_HOST="${LAN_HOST:-192.168.1.100}"
$ WAN_PORT="${WAN_PORT:-8080}"
$ LAN_PORT="${LAN_PORT:-80}"
$ echo "Using LAN_HOST=${LAN_HOST} WAN_PORT=${WAN_PORT} LAN_PORT=${LAN_PORT}"
Using LAN_HOST=* WAN_PORT=* LAN_PORT=*

# Create a temporary redirect rule in UCI firewall
$ RULE_NAME="cram_dnat_test_rule"
$ uci -q add firewall redirect >/dev/null
$ INDEX="$(uci -q show firewall | awk -F= '/^firewall.@redirect\[[0-9]+\]=redirect/{c++} END{print c-1}')"
$ uci -q set firewall.@redirect[${INDEX}].name="${RULE_NAME}"
$ uci -q set firewall.@redirect[${INDEX}].src='wan'
$ uci -q set firewall.@redirect[${INDEX}].src_dport="${WAN_PORT}"
$ uci -q set firewall.@redirect[${INDEX}].dest='lan'
$ uci -q set firewall.@redirect[${INDEX}].dest_ip="${LAN_HOST}"
$ uci -q set firewall.@redirect[${INDEX}].dest_port="${LAN_PORT}"
$ uci -q set firewall.@redirect[${INDEX}].proto='tcp'
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify a DNAT rule exists in nat PREROUTING for the WAN port to LAN host:port
$ iptables -t nat -S PREROUTING | grep -E -- "-p tcp .* --dport ${WAN_PORT} .* -j DNAT .*to:${LAN_HOST}(:${LAN_PORT})?" | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A PREROUTING * -p tcp * --dport * -j DNAT *to:*

# Cleanup: remove redirect rule
$ uci -q changes firewall | grep -q "${RULE_NAME}" || true
$ uci -q revert firewall || true
$ # Remove any redirect with name matching RULE_NAME (idempotent)
$ for i in $(uci -q show firewall | awk -F'[][]' -v n="${RULE_NAME}" '/@redirect\[/{print $2}' ); do
>   nm="$(uci -q get firewall.@redirect[$i].name || true)"; [ "$nm" = "${RULE_NAME}" ] && uci -q delete firewall.@redirect[$i] || true;
> done
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ echo "Cleaned DNAT rule ${RULE_NAME}"
Cleaned DNAT rule *
