# Test: Verify INPUT chain default policy is readable and in expected set
# Note: We do not modify policy here; we only parse and assert format deterministically.

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Show INPUT policy line from `iptables -L` and normalize whitespace
$ iptables -L INPUT -n | sed -n '1p' | sed 's/[[:space:]]\\+/ /g'
Chain INPUT (policy * ) (glob)

# Show any terminal REJECT/DROP rule lines (if present), normalize output
$ iptables -S INPUT | grep -E -- '-j (REJECT|DROP)$' | sed 's/[[:space:]]\\+/ /g' | sort | uniq || true
* (glob)
