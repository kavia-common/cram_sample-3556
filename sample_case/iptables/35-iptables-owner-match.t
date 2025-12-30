# Test: Demonstrate owner match rule insertion (skip if module not available)
# Owner match is typically meaningful for OUTPUT chain and local processes.

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Skip if owner match not available
$ iptables -m owner -h >/dev/null 2>&1 || { echo "owner-match-missing"; exit 0; }
owner-match-missing (glob)

# Create a rule for uid 0 on OUTPUT chain (allow/accept)
$ iptables -I OUTPUT 1 -m owner --uid-owner 0 -p tcp --dport 65533 -j ACCEPT 2>/dev/null || true

# Verify presence
$ iptables -S OUTPUT | grep -E -- "-m owner .* --uid-owner 0 .* -p tcp .* --dport 65533 .* -j ACCEPT" | sed 's/[[:space:]]\\+/ /g' | sort | uniq
-A OUTPUT * -m owner * --uid-owner 0 * -p tcp * --dport 65533 * -j ACCEPT

# Cleanup
$ iptables -D OUTPUT -m owner --uid-owner 0 -p tcp --dport 65533 -j ACCEPT 2>/dev/null || true
$ echo "Cleaned owner match rule"
Cleaned owner match rule
