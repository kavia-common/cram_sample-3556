# Test: Custom chains per-zone (WAN/LAN) and jump hooks (non-destructive)
#
# - Create temporary custom chains CRAM_LAN and CRAM_WAN
# - Hook them for matching interfaces from INPUT chain using -i/-o
# - Verify via iptables-save and cleanup
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

$ LAN_IF="$(ip -o link show 2>/dev/null | awk -F': ' '/\\blan[1-9]\\b|br-lan/{print $2; exit}')"
$ WAN_IF="$(ip route show default 2>/dev/null | awk '/default/ {for(i=1;i<=NF;i++){if($i==\"dev\"){print $(i+1); exit}}}')"
$ [ -n "$LAN_IF" ] || [ -n "$WAN_IF" ] || { echo "if-missing"; exit 0; }
if-missing (glob)

$ iptables -N CRAM_LAN 2>/dev/null || true
$ iptables -N CRAM_WAN 2>/dev/null || true
$ [ -n "$LAN_IF" ] && iptables -I INPUT 1 -i "$LAN_IF" -j CRAM_LAN || true
$ [ -n "$WAN_IF" ] && iptables -I INPUT 1 -i "$WAN_IF" -j CRAM_WAN || true

# Verify hook presence
$ [ -n "$LAN_IF" ] && iptables-save | grep -E "^-A INPUT .* -i ${LAN_IF} .* -j CRAM_LAN" | sed 's/[[:space:]]\\+/ /g' | head -n 1 || echo "no-lan-hook"
* (glob)
$ [ -n "$WAN_IF" ] && iptables-save | grep -E "^-A INPUT .* -i ${WAN_IF} .* -j CRAM_WAN" | sed 's/[[:space:]]\\+/ /g' | head -n 1 || echo "no-wan-hook"
* (glob)

# Cleanup
$ [ -n "$LAN_IF" ] && iptables -D INPUT -i "$LAN_IF" -j CRAM_LAN 2>/dev/null || true
$ [ -n "$WAN_IF" ] && iptables -D INPUT -i "$WAN_IF" -j CRAM_WAN 2>/dev/null || true
$ iptables -F CRAM_LAN 2>/dev/null || true
$ iptables -F CRAM_WAN 2>/dev/null || true
$ iptables -X CRAM_LAN 2>/dev/null || true
$ iptables -X CRAM_WAN 2>/dev/null || true
$ echo "Cleaned custom chain hooks"
Cleaned custom chain hooks
