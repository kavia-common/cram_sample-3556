# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Add custom iptables rule via /etc/firewall.user and verify persistence after reload
# Notes:
#  - Uses R alias; deterministic normalized checks; full cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Backup firewall.user and append tagged rule:

  $ R 'USER_FILE="/etc/firewall.user"; BAK_FILE="/tmp/firewall.user.cram.bak"; [ -f "$USER_FILE" ] && cp "$USER_FILE" "$BAK_FILE" || touch "$BAK_FILE"; TAG="CRAM_CUSTOM_RULE_$$"; echo "# ${TAG}" >> "$USER_FILE"; echo "iptables -I INPUT -p tcp --dport 65530 -j ACCEPT" >> "$USER_FILE"; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2; echo ok'
  ok

Verify presence (normalized):

  $ R 'iptables -S INPUT 2>/dev/null | grep -E -- "-p tcp .* --dport 65530 .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A INPUT * -p tcp * --dport 65530 * -j ACCEPT

Reload to confirm persistence:

  $ R '/etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2; iptables -S INPUT 2>/dev/null | grep -E -- "-p tcp .* --dport 65530 .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A INPUT * -p tcp * --dport 65530 * -j ACCEPT

Cleanup and restore:

  $ R 'mv "$BAK_FILE" "$USER_FILE" 2>/dev/null || true; /etc/init.d/firewall reload >/dev/null 2>&1 || true; sleep 2; iptables -D INPUT -p tcp --dport 65530 -j ACCEPT 2>/dev/null || true; echo "Restored firewall.user and cleaned custom rule"'
  Restored firewall.user and cleaned custom rule
