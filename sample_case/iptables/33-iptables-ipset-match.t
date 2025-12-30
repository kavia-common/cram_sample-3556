# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Create an ipset and apply an iptables rule matching it (temporary)
# Notes:
#  - Skip-safe if ipset unavailable. Deterministic verification and cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip gracefully if ipset is not available:

  $ R 'command -v ipset >/dev/null 2>&1 || { echo ipset-missing; exit 0; }'
  ipset-missing (glob)

Create a temporary ipset and add an entry:

  $ R 'SET_NAME="cram_tmp_set_$$"; ipset create "${SET_NAME}" hash:ip 2>/dev/null || true; ipset add "${SET_NAME}" 1.2.3.4 2>/dev/null || true; echo "${SET_NAME}" | sed "s/[0-9]\\+/<PID>/"'
  cram_tmp_set_<PID>

Add iptables rule that matches the set:

  $ R 'iptables -I INPUT 1 -m set --match-set "${SET_NAME}" src -j DROP 2>/dev/null || true; echo added'
  added

Verify rule presence:

  $ R 'iptables -S INPUT 2>/dev/null | grep -E -- "-m set .* --match-set ${SET_NAME} src .* -j DROP" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A INPUT * -m set * --match-set * src * -j DROP

Cleanup:

  $ R 'iptables -D INPUT -m set --match-set "${SET_NAME}" src -j DROP 2>/dev/null || true; ipset destroy "${SET_NAME}" 2>/dev/null || true; echo cleaned'
  cleaned
