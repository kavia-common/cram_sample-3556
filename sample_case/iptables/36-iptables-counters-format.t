# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Read iptables counters for INPUT chain deterministically (format only)
# Notes:
#  - Output normalized; does not mutate system state.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Show header and two lines (normalized):

  $ R "iptables -L INPUT -n -v 2>/dev/null | sed 's/[[:space:]]\\+/ /g' | head -n 3 || echo missing"
  Chain INPUT (policy * (glob)
  *
  *
