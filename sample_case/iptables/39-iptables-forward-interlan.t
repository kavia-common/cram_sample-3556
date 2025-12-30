# Test: Inter-LAN isolation rules (drop/accept between LAN subnets) with explicit ACCEPT exceptions
#
# - Detects multiple LAN interfaces (lan1..lan3 or bridge br-lan + vlan subifs)
# - Inserts temporary FORWARD rules to DROP inter-LAN and one ACCEPT exception.
# - Verifies via iptables-save FORWARD lines normalized.
# - Cleans up by deleting temporary rules.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Discover two distinct LAN interfaces
$ LANS="$(ip -o link show 2>/dev/null | awk -F': ' '/\\blan[1-9]\\b|br-lan|br-lan\\.[0-9]+/{print $2}' | head -n 3)"
$ LAN_A="$(echo "$LANS" | sed -n '1p')"
$ LAN_B="$(echo "$LANS" | sed -n '2p')"
$ [ -n "$LAN_A" ] && [ -n "$LAN_B" ] || { echo "insufficient-lan-if"; exit 0; }
insufficient-lan-if (glob)

# Insert isolation DROP (LAN_A -> LAN_B) and ACCEPT exception tcp/53
$ iptables -I FORWARD 1 -i "$LAN_A" -o "$LAN_B" -j DROP
$ iptables -I FORWARD 1 -i "$LAN_A" -o "$LAN_B" -p tcp --dport 53 -j ACCEPT

# Verify both rules present deterministically
$ iptables-save | grep -E "^-A FORWARD .* -i ${LAN_A} .* -o ${LAN_B} .* -p tcp .* --dport 53 .* -j ACCEPT" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A FORWARD * -i * -o * -p tcp * --dport 53 * -j ACCEPT
$ iptables-save | grep -E "^-A FORWARD .* -i ${LAN_A} .* -o ${LAN_B} .* -j DROP" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A FORWARD * -i * -o * -j DROP

# Cleanup rules (delete ACCEPT then DROP)
$ iptables -D FORWARD -i "$LAN_A" -o "$LAN_B" -p tcp --dport 53 -j ACCEPT 2>/dev/null || true
$ iptables -D FORWARD -i "$LAN_A" -o "$LAN_B" -j DROP 2>/dev/null || true
$ echo "Cleaned inter-LAN isolation rules $LAN_A->$LAN_B"
Cleaned inter-LAN isolation rules *
