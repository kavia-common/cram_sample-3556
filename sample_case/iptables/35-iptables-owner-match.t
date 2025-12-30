# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Demonstrate owner match rule insertion (skip if module not available)
# Notes:
#  - Uses OUTPUT chain; deterministic verification; cleans up.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Skip if owner match not available:

  $ R 'iptables -m owner -h >/dev/null 2>&1 || { echo owner-match-missing; exit 0; }'
  owner-match-missing (glob)

Create a rule for uid 0 on OUTPUT chain:

  $ R 'iptables -I OUTPUT 1 -m owner --uid-owner 0 -p tcp --dport 65533 -j ACCEPT 2>/dev/null || true; echo added'
  added

Verify presence:

  $ R 'iptables -S OUTPUT 2>/dev/null | grep -E -- "-m owner .* --uid-owner 0 .* -p tcp .* --dport 65533 .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A OUTPUT * -m owner * --uid-owner 0 * -p tcp * --dport 65533 * -j ACCEPT

Cleanup:

  $ R 'iptables -D OUTPUT -m owner --uid-owner 0 -p tcp --dport 65533 -j ACCEPT 2>/dev/null || true; echo cleaned'
  cleaned
