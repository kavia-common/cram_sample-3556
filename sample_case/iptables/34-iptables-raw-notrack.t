# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Add a NOTRACK rule in raw table and verify (temporary)
# Notes:
#  - Non-destructive; rule removed in cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Insert NOTRACK rule for UDP dport 65532:

  $ R 'iptables -t raw -I PREROUTING 1 -p udp --dport 65532 -j NOTRACK 2>/dev/null || true; echo added'
  added

Verify rule presence:

  $ R 'iptables -t raw -S PREROUTING 2>/dev/null | grep -E -- "-p udp .* --dport 65532 .* -j NOTRACK" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A PREROUTING * -p udp * --dport 65532 * -j NOTRACK

Cleanup:

  $ R 'iptables -t raw -D PREROUTING -p udp --dport 65532 -j NOTRACK 2>/dev/null || true; echo cleaned'
  cleaned
