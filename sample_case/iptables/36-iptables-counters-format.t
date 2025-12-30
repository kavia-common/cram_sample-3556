# Test: Read iptables counters for INPUT chain deterministically (format only)

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Show header and one rule line with normalized spaces
$ iptables -L INPUT -n -v | sed 's/[[:space:]]\\+/ /g' | head -n 3
Chain INPUT (policy *) (glob)
*
*
