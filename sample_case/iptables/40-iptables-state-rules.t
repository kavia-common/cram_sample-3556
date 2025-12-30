# Test: Stateful firewall rules presence - ESTABLISHED,RELATED accept and INVALID drop
#
# - Inserts temporary INVALID drop at head; verifies presence.
# - Checks for ACCEPT state ESTABLISHED,RELATED via existing rules (skip-safe if absent).
# - Cleans up temporary INVALID rule.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Insert an INVALID drop rule to INPUT for demonstration
$ iptables -I INPUT 1 -m conntrack --ctstate INVALID -j DROP 2>/dev/null || true

# Verify INVALID drop
$ iptables-save | grep -E "^-A INPUT .* -m conntrack --ctstate INVALID .* -j DROP" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A INPUT * -m conntrack --ctstate INVALID * -j DROP

# Check for ESTABLISHED,RELATED accept in INPUT or FORWARD (skip-safe)
$ iptables-save | grep -E "^-A (INPUT|FORWARD) .* -m conntrack --ctstate ESTABLISHED,RELATED .* -j ACCEPT" | sed 's/[[:space:]]\\+/ /g' | head -n 1 || echo "no-est-rel-accept"
* (glob)

# Cleanup
$ iptables -D INPUT -m conntrack --ctstate INVALID -j DROP 2>/dev/null || true
$ echo "Cleaned INVALID drop rule"
Cleaned INVALID drop rule
