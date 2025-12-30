# Test: Add custom iptables rule via /etc/firewall.user and verify it persists after reload

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Backup firewall.user
$ USER_FILE="/etc/firewall.user"
$ BAK_FILE="/tmp/firewall.user.cram.bak"
$ [ -f "${USER_FILE}" ] && cp "${USER_FILE}" "${BAK_FILE}" || touch "${BAK_FILE}"

# Append a tagged custom rule to INPUT chain that should persist after reload
$ TAG="CRAM_CUSTOM_RULE_$$"
$ echo "# ${TAG}" >> "${USER_FILE}"
$ echo "iptables -I INPUT -p tcp --dport 65530 -j ACCEPT" >> "${USER_FILE}"

# Reload firewall to execute firewall.user
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2

# Verify rule presence (grep for dport 65530 and ACCEPT)
$ iptables -S INPUT | grep -E -- '-p tcp .* --dport 65530 .* -j ACCEPT' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A INPUT * -p tcp * --dport 65530 * -j ACCEPT

# Reload again to test persistence
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2
$ iptables -S INPUT | grep -E -- '-p tcp .* --dport 65530 .* -j ACCEPT' | sed 's/[[:space:]]\+/ /g' | sort | uniq
-A INPUT * -p tcp * --dport 65530 * -j ACCEPT

# Cleanup: restore firewall.user and reload, also remove rule if still present
$ mv "${BAK_FILE}" "${USER_FILE}" 2>/dev/null || true
$ /etc/init.d/firewall reload >/dev/null 2>&1 || true
$ sleep 2
$ # Ensure rule absent (best-effort delete)
$ iptables -D INPUT -p tcp --dport 65530 -j ACCEPT 2>/dev/null || true
$ echo "Restored firewall.user and cleaned custom rule"
Restored firewall.user and cleaned custom rule
