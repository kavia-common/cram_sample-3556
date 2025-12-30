# Test: Basic ip6tables parity with IPv4 scenarios (skip if ip6tables not available)
#
# - Inserts LOG and ACCEPT rules with rate-limit and MARK in mangle, if available.
# - Deterministic verification via ip6tables-save filtered output.
# - Cleans up rules; skip-safe on absence of ip6tables or interfaces.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Skip if ip6tables missing
$ command -v ip6tables >/dev/null 2>&1 || { echo "ip6tables-missing"; exit 0; }
ip6tables-missing (glob)

$ LAN_IF6="$(ip -o -6 link show 2>/dev/null | awk -F': ' '/\\blan[1-9]\\b|br-lan/{print $2; exit}')"
$ [ -n "$LAN_IF6" ] || LAN_IF6="$(ip -o link show | awk -F': ' '/\\blan[1-9]\\b|br-lan/{print $2; exit}')"

# Insert rules
$ LP="CRAM_IP6_LOG_$$"
$ ip6tables -I INPUT 1 -p tcp --dport 65010 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4
$ ip6tables -I INPUT 2 -p tcp --dport 65010 -j ACCEPT
$ ip6tables -t mangle -I PREROUTING 1 ${LAN_IF6:+-i "$LAN_IF6"} -p tcp --dport 65011 -j MARK --set-mark 0x66 2>/dev/null || true

# Verify presence
$ ip6tables-save | grep -E "^-A INPUT .* -p tcp .* --dport 65010 .* -m limit .* -j LOG .*${LP}" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A INPUT * -p tcp * --dport 65010 * -m limit * -j LOG * (glob)
$ ip6tables-save | grep -E "^-A INPUT .* -p tcp .* --dport 65010 .* -j ACCEPT" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A INPUT * -p tcp * --dport 65010 * -j ACCEPT
$ ip6tables-save -t mangle | grep -E "^-A PREROUTING .* (--dport 65011).* -j MARK" | sed 's/[[:space:]]\\+/ /g' | head -n 1 || echo "no-ipv6-mangle-mark"
* (glob)

# Cleanup
$ ip6tables -D INPUT -p tcp --dport 65010 -j ACCEPT 2>/dev/null || true
$ ip6tables -D INPUT -p tcp --dport 65010 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true
$ ip6tables -t mangle -D PREROUTING ${LAN_IF6:+-i "$LAN_IF6"} -p tcp --dport 65011 -j MARK --set-mark 0x66 2>/dev/null || true
$ echo "Cleaned ip6tables rules"
Cleaned ip6tables rules
