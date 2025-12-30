# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Basic ip6tables parity with IPv4 scenarios (temporary)
# Notes:
#  - Skip-safe if ip6tables missing. Deterministic checks and cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip if ip6tables missing:

  $ R 'command -v ip6tables >/dev/null 2>&1 || { echo ip6tables-missing; exit 0; }'
  ip6tables-missing (glob)

Detect LAN_IF6 (optional):

  $ R 'LAN_IF6="$(ip -o -6 link show 2>/dev/null | awk -F\": \" \"/\\blan[1-9]\\b|\\bbr-lan\\b/{print $2; exit}\")"; [ -n \"$LAN_IF6\" ] || LAN_IF6=\"$(ip -o link show | awk -F\": \" \"/\\blan[1-9]\\b|\\bbr-lan\\b/{print $2; exit}\")\"; echo OK'
  OK

Insert LOG/ACCEPT and optional mangle MARK:

  $ R 'LP="CRAM_IP6_LOG_$$"; ip6tables -I INPUT 1 -p tcp --dport 65010 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4; ip6tables -I INPUT 2 -p tcp --dport 65010 -j ACCEPT; ip6tables -t mangle -I PREROUTING 1 ${LAN_IF6:+-i "$LAN_IF6"} -p tcp --dport 65011 -j MARK --set-mark 0x66 2>/dev/null || true; echo added'
  added

Verify LOG rule:

  $ R 'ip6tables-save | grep -E "^-A INPUT .* -p tcp .* --dport 65010 .* -m limit .* -j LOG .*${LP}" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A INPUT * -p tcp * --dport 65010 * -m limit * -j LOG * (glob)

Verify ACCEPT rule:

  $ R 'ip6tables-save | grep -E "^-A INPUT .* -p tcp .* --dport 65010 .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A INPUT * -p tcp * --dport 65010 * -j ACCEPT

Verify optional mangle MARK:

  $ R 'ip6tables-save -t mangle | grep -E "^-A PREROUTING .* (--dport 65011).* -j MARK" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || echo no-ipv6-mangle-mark'
  * (glob)

Cleanup:

  $ R 'ip6tables -D INPUT -p tcp --dport 65010 -j ACCEPT 2>/dev/null || true; ip6tables -D INPUT -p tcp --dport 65010 -m limit --limit 2/min --limit-burst 5 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true; ip6tables -t mangle -D PREROUTING ${LAN_IF6:+-i "$LAN_IF6"} -p tcp --dport 65011 -j MARK --set-mark 0x66 2>/dev/null || true; echo cleaned'
  cleaned
