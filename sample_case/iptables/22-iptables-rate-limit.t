# Test: Add limit module rule with counters and verify presence
# Note: On quiet systems counters may remain 0; we validate rule presence deterministically.

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Insert a rate limit rule into INPUT for ICMP echo-request
$ iptables -I INPUT 1 -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 3 -j ACCEPT

# Normalize and verify rule presence
$ iptables -S INPUT | grep -E -- '-p icmp .*--icmp-type echo-request .* -m limit .* --limit .* --limit-burst .* -j ACCEPT' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A INPUT * -p icmp * --icmp-type echo-request * -m limit * --limit * --limit-burst * -j ACCEPT

# Show counters deterministically via iptables -L with numeric, but only verify the header line containing ACCEPT
$ iptables -L INPUT -n -v | awk 'NR==1 || /ACCEPT/ {print}' | sed 's/[[:space:]]\+/ /g' | head -n 3
Chain INPUT (policy *)

# Cleanup: remove the inserted rule
$ iptables -D INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 3 -j ACCEPT 2>/dev/null || true
$ echo "Cleaned rate-limit rule"
Cleaned rate-limit rule
