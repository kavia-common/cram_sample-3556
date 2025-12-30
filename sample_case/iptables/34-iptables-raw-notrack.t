# Test: Add a NOTRACK rule in raw table and verify

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Insert NOTRACK rule for local UDP dport 65532
$ iptables -t raw -I PREROUTING 1 -p udp --dport 65532 -j NOTRACK 2>/dev/null || true

# Verify rule presence
$ iptables -t raw -S PREROUTING | grep -E -- "-p udp .* --dport 65532 .* -j NOTRACK" | sed 's/[[:space:]]\\+/ /g' | sort | uniq
-A PREROUTING * -p udp * --dport 65532 * -j NOTRACK

# Cleanup
$ iptables -t raw -D PREROUTING -p udp --dport 65532 -j NOTRACK 2>/dev/null || true
$ echo "Cleaned NOTRACK rule"
Cleaned NOTRACK rule
