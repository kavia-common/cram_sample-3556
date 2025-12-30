# Test: WAN logging with rate limit for suspected scans
#
# - Detects WAN interface from default route or common names (pppoe-wan, eth-wan).
# - Adds a rule to log and drop TCP SYN to closed port with rate-limit.
# - Verifies deterministic presence via iptables-save.
# - Cleans up rules.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Detect WAN interface
$ WAN_IF="$(ip route show default 2>/dev/null | awk '/default/ {for(i=1;i<=NF;i++){if($i==\"dev\"){print $(i+1); exit}}}')"
$ [ -n "$WAN_IF" ] || WAN_IF="$(ip -o link show | awk -F': ' '/pppoe-wan|eth[0-9]+|wan[0-9]?/ {print $2; exit}')"
$ [ -n "$WAN_IF" ] || { echo "wan-if-missing"; exit 0; }
wan-if-missing (glob)

$ LP="CRAM_WAN_LOG_$$"
$ iptables -I INPUT 1 -i "$WAN_IF" -p tcp --syn --dport 65000 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4
$ iptables -I INPUT 2 -i "$WAN_IF" -p tcp --syn --dport 65000 -j DROP

# Verify presence
$ iptables-save | grep -E "^-A INPUT .* -i ${WAN_IF} .* -p tcp .* --dport 65000 .* -m limit .* -j LOG .*${LP}" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A INPUT * -i * -p tcp * --dport 65000 * -m limit * -j LOG * (glob)
$ iptables-save | grep -E "^-A INPUT .* -i ${WAN_IF} .* -p tcp .* --dport 65000 .* -j DROP" | sed 's/[[:space:]]\\+/ /g' | head -n 1
-A INPUT * -i * -p tcp * --dport 65000 * -j DROP

# Cleanup
$ iptables -D INPUT -i "$WAN_IF" -p tcp --syn --dport 65000 -j DROP 2>/dev/null || true
$ iptables -D INPUT -i "$WAN_IF" -p tcp --syn --dport 65000 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true
$ echo "Cleaned WAN logging rules on ${WAN_IF}"
Cleaned WAN logging rules on *
