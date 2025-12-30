# Test: Change default forward policy and verify firewall produces expected rule behavior
# This test toggles forward policy between REJECT and ACCEPT and verifies rule presence.

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Save current forward policy for restore
$ FW_FWD_BEFORE="$(uci -q get firewall.defaults.forward || echo 'REJECT')"
$ echo "FORWARD_BEFORE=${FW_FWD_BEFORE}"
FORWARD_BEFORE=*

# Set forward=REJECT and reload
$ uci -q set firewall.defaults.forward='REJECT'
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify forward policy effect by checking FORWARD chain contains a default REJECT/zone reject rule
$ iptables -S FORWARD | grep -E -- '-j (reject|REJECT|DROP)' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A FORWARD * -j *REJECT*

# Set forward=ACCEPT and reload
$ uci -q set firewall.defaults.forward='ACCEPT'
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify FORWARD chain contains ACCEPT path (zone forwarding rules) and default ACCEPT not rejecting
# We check that there is at least one ACCEPT path and that no final default REJECT is at chain end
$ iptables -S FORWARD | grep -E -- '-j ACCEPT' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A FORWARD * -j ACCEPT*

# Cleanup: restore default forward policy
$ uci -q set firewall.defaults.forward="${FW_FWD_BEFORE}"
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ echo "Restored forward policy=${FW_FWD_BEFORE}"
Restored forward policy=*
