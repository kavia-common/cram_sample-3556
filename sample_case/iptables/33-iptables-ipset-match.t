# Test: Create an ipset and apply an iptables rule matching it

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Skip gracefully if ipset is not available
$ if ! command -v ipset >/dev/null 2>&1; then echo "ipset-missing"; exit 0; fi
ipset-missing (glob)

# Create a temporary ipset
$ SET_NAME="cram_tmp_set_$$"
$ ipset create "${SET_NAME}" hash:ip 2>/dev/null || true
$ ipset add "${SET_NAME}" 1.2.3.4 2>/dev/null || true

# Add iptables rule that matches the set
$ iptables -I INPUT 1 -m set --match-set "${SET_NAME}" src -j DROP 2>/dev/null || true

# Verify rule presence
$ iptables -S INPUT | grep -E -- "-m set .* --match-set ${SET_NAME} src .* -j DROP" | sed 's/[[:space:]]\\+/ /g' | sort | uniq
-A INPUT * -m set * --match-set * src * -j DROP

# Cleanup: remove rule and set
$ iptables -D INPUT -m set --match-set "${SET_NAME}" src -j DROP 2>/dev/null || true
$ ipset destroy "${SET_NAME}" 2>/dev/null || true
$ echo "Cleaned ipset rule and set"
Cleaned ipset rule and set
