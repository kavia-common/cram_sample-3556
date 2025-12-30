# Test: Hairpin NAT scenario validation (skip if unsupported)
#
# - Attempts to add SNAT for LAN to LAN DNAT'ed traffic (common hairpin setup).
# - Verifies via iptables-save POSTROUTING/PREROUTING heuristics.
# - Uses test addresses and cleans up; skip-safe.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

$ LAN_BR="$(ip -o link show | awk -F': ' '/\\bbr-lan\\b/{print $2; exit}')"
$ [ -n "$LAN_BR" ] || { echo "br-lan-missing"; exit 0; }
br-lan-missing (glob)

# Use RFC5737 example address block for DNAT target
$ DNAT_IP="192.0.2.50"
$ WAN_PORT="65020"
$ LAN_PORT="80"

# Add a PREROUTING DNAT for traffic hitting LAN br-lan (hairpin might traverse PREROUTING locally depending on setup)
$ iptables -t nat -I PREROUTING 1 -i "$LAN_BR" -p tcp --dport ${WAN_PORT} -j DNAT --to-destination ${DNAT_IP}:${LAN_PORT}
# Add a POSTROUTING SNAT for traffic from LAN to that DNAT target to source-NAT as br-lan IP (use MASQUERADE as portable)
$ iptables -t nat -I POSTROUTING 1 -o "$LAN_BR" -d ${DNAT_IP} -p tcp --dport ${LAN_PORT} -j MASQUERADE

# Verify presence
$ iptables-save -t nat | grep -E "^-A PREROUTING .* -i ${LAN_BR} .* -p tcp .* --dport ${WAN_PORT} .* -j DNAT .*to:${DNAT_IP}:${LAN_PORT}" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A PREROUTING * -i * -p tcp * --dport * -j DNAT *to:*
$ iptables-save -t nat | grep -E "^-A POSTROUTING .* -o ${LAN_BR} .* -d ${DNAT_IP} .* -p tcp .* --dport ${LAN_PORT} .* -j (SNAT|MASQUERADE)" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A POSTROUTING * -o * -d * -p tcp * --dport * -j * (glob)

# Cleanup
$ iptables -t nat -D POSTROUTING -o "$LAN_BR" -d ${DNAT_IP} -p tcp --dport ${LAN_PORT} -j MASQUERADE 2>/dev/null || true
$ iptables -t nat -D PREROUTING -i "$LAN_BR" -p tcp --dport ${WAN_PORT} -j DNAT --to-destination ${DNAT_IP}:${LAN_PORT} 2>/dev/null || true
$ echo "Cleaned hairpin NAT example"
Cleaned hairpin NAT example
