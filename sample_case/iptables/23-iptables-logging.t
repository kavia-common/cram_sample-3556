# Test: Add iptables LOG rule and verify kernel log entries appear
# Uses logread if present; falls back to dmesg. We avoid flakiness by grepping for a unique prefix.

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Unique log prefix
$ LP="CRAM_IPT_LOG_$$"

# Insert a LOG rule early in INPUT to log tcp dport 65531 packets
$ iptables -I INPUT 1 -p tcp --dport 65531 -j LOG --log-prefix "${LP} " --log-level 4

# Generate a local packet if possible (best-effort using localhost; may not hit INPUT on all setups)
$ nc -z -w1 127.0.0.1 65531 2>/dev/null || true
$ sleep 2

# Check logs for the prefix
$ if command -v logread >/dev/null 2>&1; then logread | grep -F "${LP}" | tail -n 1 | sed 's/[[:space:]]\+/ /g'; else dmesg | grep -F "${LP}" | tail -n 1 | sed "s/[[:space:]]\\+/ /g"; fi
*${LP}*

# Cleanup: remove rule
$ iptables -D INPUT -p tcp --dport 65531 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true
$ echo "Cleaned LOG rule"
Cleaned LOG rule
