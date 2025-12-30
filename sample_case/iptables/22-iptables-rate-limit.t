# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Add limit module rule with counters and verify presence (temporary)
# Notes:
#  - Uses R alias; normalized outputs; full cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Insert rate-limit rule (ICMP echo-request):

  $ R 'iptables -I INPUT 1 -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 3 -j ACCEPT 2>/dev/null || true; echo added'
  added

Verify rule presence (normalized):

  $ R 'iptables -S INPUT 2>/dev/null | grep -E -- "-p icmp .*--icmp-type echo-request .* -m limit .* --limit .* --limit-burst .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | sort | uniq'
  -A INPUT * -p icmp * --icmp-type echo-request * -m limit * --limit * --limit-burst * -j ACCEPT

Show header line deterministically:

  $ R 'iptables -L INPUT -n -v 2>/dev/null | sed "s/[[:space:]]\\+/ /g" | sed -n "1p" || echo missing'
  Chain INPUT (policy * (glob)

Cleanup:

  $ R 'iptables -D INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 3 -j ACCEPT 2>/dev/null || true; echo "Cleaned rate-limit rule"'
  Cleaned rate-limit rule
