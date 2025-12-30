# Test: Enable MASQUERADE on WAN zone and verify NAT table has MASQUERADE rule

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Save current masquerade setting to restore later
$ WAN_MASQ_BEFORE="$(uci -q get firewall.@zone[?name==wan].masq || true)"
$ echo "WAN_MASQ_BEFORE=${WAN_MASQ_BEFORE}"
WAN_MASQ_BEFORE=*

# Enable masquerade on WAN via UCI and reload firewall
$ uci -q set firewall.@zone[?name==wan].masq='1'
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify MASQUERADE rule appears in nat POSTROUTING related to wan
# We allow different interface matches; check presence of '-j MASQUERADE'
$ iptables -t nat -S POSTROUTING | grep -E -- '-j MASQUERADE' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A POSTROUTING * -j MASQUERADE*

# Cleanup: restore previous masquerade setting
$ if [ -n "${WAN_MASQ_BEFORE}" ]; then
>   uci -q set firewall.@zone[?name==wan].masq="${WAN_MASQ_BEFORE}";
> else
>   uci -q del firewall.@zone[?name==wan].masq || true;
> fi
$ uci -q commit firewall
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ echo "Restored masquerade=${WAN_MASQ_BEFORE:-<unset>}"
Restored masquerade=*
