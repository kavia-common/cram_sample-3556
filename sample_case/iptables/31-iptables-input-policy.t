# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify INPUT chain default policy formatting deterministically (read-only)
# Notes:
#  - Does not modify policy; uses normalized expectations.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Show INPUT policy line from iptables -L (normalized):

  $ R "iptables -L INPUT -n 2>/dev/null | sed -n '1p' | sed 's/[[:space:]]\\+/ /g' || echo missing"
  Chain INPUT (policy * (glob)

Show any terminal REJECT/DROP rules (if present), normalized:

  $ R "iptables -S INPUT 2>/dev/null | grep -E -- '-j (REJECT|DROP)$' | sed 's/[[:space:]]\\+/ /g' | sort | uniq || true"
  * (glob)
