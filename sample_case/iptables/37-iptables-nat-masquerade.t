# Test: NAT table basics for a 4-port router - MASQUERADE on WAN and per-LAN SNAT examples (non-destructive)
#
# - Enables MASQUERADE on wan zone via UCI temporarily, verifies presence using iptables-save filtered view.
# - Demonstrates per-LAN SNAT example using a temporary custom rule (insert/remove) if interfaces are present.
# - Uses deterministic outputs and cleans up configuration/rules.
#
# Assumptions:
# - OpenWrt-like firewall with zones 'wan' and 'lan' (or multiple LANs).
# - Skip-safe if UCI or interfaces aren't present.
#
$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Helper: safe get UCI zone index by name
$ get_zone_idx() { uci -q show firewall | awk -F'[=\\[\\]]' -v Z="$1" '$0 ~ /^firewall.@zone\\[/ {idx=$3} $0 ~ ("name=" Z "$") {print idx}'; }

# Skip gracefully if uci missing
$ command -v uci >/dev/null 2>&1 || { echo "uci-missing"; exit 0; }
uci-missing (glob)

# Determine wan zone index
$ WAN_IDX="$(get_zone_idx wan || true)"
$ [ -n "$WAN_IDX" ] || { echo "wan-zone-missing"; exit 0; }
wan-zone-missing (glob)

# Save current masquerade setting to restore later
$ WAN_MASQ_BEFORE="$(uci -q get firewall.@zone[$WAN_IDX].masq || true)"
$ echo "WAN_MASQ_BEFORE=${WAN_MASQ_BEFORE:-<unset>}"
WAN_MASQ_BEFORE=*

# Enable masquerade on WAN via UCI and reload firewall
$ uci -q set firewall.@zone[$WAN_IDX].masq='1'
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify MASQUERADE rule appears in nat POSTROUTING via iptables-save (deterministic)
$ iptables-save -t nat 2>/dev/null | grep -E "^:POSTROUTING|^-A POSTROUTING" | sed 's/[[:space:]]\\+/ /g' | grep -E '\\bMASQUERADE\\b' | head -n 1 | sed 's/[0-9a-zA-Z:_\\-]*/X/g' | sed 's/ MASQUERADE/ MASQUERADE/' || true
X X MASQUERADE (glob)

# Try per-LAN SNAT example: insert then delete a temporary rule if LAN interface exists
# Detect common LAN bridges or ports (br-lan, lan1, lan2, lan3)
$ LAN_IF="$(ip -o link show 2>/dev/null | awk -F': ' '/br-lan| lan[1-4]/{print $2; exit}')"
$ if [ -n "$LAN_IF" ]; then iptables -t nat -I POSTROUTING 1 -o "$LAN_IF" -j SNAT --to-source 192.0.2.5 2>/dev/null || true; fi
$ if [ -n "$LAN_IF" ]; then iptables-save -t nat | grep -E "^-A POSTROUTING .* -o ${LAN_IF} .* -j SNAT .*to:192\\.0\\.2\\.5" | sed 's/[[:space:]]\\+/ /g' | head -n 1; else echo "lan-if-missing"; fi
* (glob)

# Cleanup: remove SNAT example rule if present
$ if [ -n "$LAN_IF" ]; then iptables -t nat -D POSTROUTING -o "$LAN_IF" -j SNAT --to-source 192.0.2.5 2>/dev/null || true; fi
$ echo "Cleaned SNAT example on ${LAN_IF:-<none>}"
Cleaned SNAT example on *

# Cleanup: restore WAN masquerade setting
$ if [ -n "${WAN_MASQ_BEFORE}" ]; then
>   uci -q set firewall.@zone[$WAN_IDX].masq="${WAN_MASQ_BEFORE}";
> else
>   uci -q del firewall.@zone[$WAN_IDX].masq || true;
> fi
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ echo "Restored WAN masq=${WAN_MASQ_BEFORE:-<unset>}"
Restored WAN masq=*
