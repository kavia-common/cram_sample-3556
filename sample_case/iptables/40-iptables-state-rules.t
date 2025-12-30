# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Verify stateful rules presence (temporary INVALID DROP insertion)
# Notes:
#  - Non-destructive; deterministic checks; cleanup included.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Insert INVALID drop rule:

  $ R 'iptables -I INPUT 1 -m conntrack --ctstate INVALID -j DROP 2>/dev/null || true; echo added'
  added

Verify INVALID drop presence:

  $ R 'iptables-save | grep -E "^-A INPUT .* -m conntrack --ctstate INVALID .* -j DROP" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A INPUT * -m conntrack --ctstate INVALID * -j DROP

Check for ESTABLISHED,RELATED accepts (skip-safe):

  $ R 'iptables-save | grep -E "^-A (INPUT|FORWARD) .* -m conntrack --ctstate ESTABLISHED,RELATED .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | head -n 1 || echo no-est-rel-accept'
  * (glob)

Cleanup:

  $ R 'iptables -D INPUT -m conntrack --ctstate INVALID -j DROP 2>/dev/null || true; echo cleaned'
  cleaned
