# Test: Insert and verify a MARK rule in mangle table PREROUTING

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Insert MARK rule with unique fwmark value
$ FW_MARK="0x1a2b"
$ iptables -t mangle -I PREROUTING 1 -p tcp --dport 65520 -j MARK --set-mark ${FW_MARK}

# Verify rule presence (normalize whitespace)
$ iptables -t mangle -S PREROUTING | grep -E -- "-p tcp .* --dport 65520 .* -j MARK .* --set-xmark ${FW_MARK}/0xffffffff|--set-mark ${FW_MARK}" | sed 's/[[:space:]]\\+/ /g' | sort | uniq
-A PREROUTING * -p tcp * --dport 65520 * -j MARK * (glob)

# Cleanup: delete the rule
$ iptables -t mangle -D PREROUTING -p tcp --dport 65520 -j MARK --set-mark ${FW_MARK} 2>/dev/null || true
$ iptables -t mangle -D PREROUTING -p tcp --dport 65520 -j MARK --set-xmark ${FW_MARK}/0xffffffff 2>/dev/null || true
$ echo "Cleaned mangle mark rule"
Cleaned mangle mark rule
