# Test: QoS/marking in mangle table per-interface (non-destructive)
#
# - Detect a LAN interface and mark traffic destined to WAN port 60000.
# - Verifies presence via iptables-save in mangle table.
# - Cleans up.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

$ LAN_IF="$(ip -o link show 2>/dev/null | awk -F': ' '/\\blan[1-9]\\b|br-lan/{print $2; exit}')"
$ [ -n "$LAN_IF" ] || { echo "lan-if-missing"; exit 0; }
lan-if-missing (glob)

$ FW_MARK="0x3c01"
$ iptables -t mangle -I PREROUTING 1 -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-mark ${FW_MARK}
$ iptables-save -t mangle | grep -E "^-A PREROUTING .* -i ${LAN_IF} .* -p tcp .* --dport 60000 .* -j MARK .* (set-xmark ${FW_MARK}/0xffffffff|set-mark ${FW_MARK})" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A PREROUTING * -i * -p tcp * --dport 60000 * -j MARK * (glob)

$ iptables -t mangle -D PREROUTING -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-mark ${FW_MARK} 2>/dev/null || true
$ iptables -t mangle -D PREROUTING -i "$LAN_IF" -p tcp --dport 60000 -j MARK --set-xmark ${FW_MARK}/0xffffffff 2>/dev/null || true
$ echo "Cleaned mangle mark on ${LAN_IF}"
Cleaned mangle mark on *
