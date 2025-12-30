# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Add iptables LOG rule and verify log entry appears (temporary)
# Notes:
#  - Uses R alias; normalized outputs; cleanup included.
#  - Best-effort generation of traffic; tolerate missing log lines by matching glob.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Insert LOG rule with unique prefix:

  $ R 'LP="CRAM_IPT_LOG_$$"; iptables -I INPUT 1 -p tcp --dport 65531 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true; echo "${LP}" | sed "s/[0-9]\\+/<PID>/"'
  CRAM_IPT_LOG_<PID>

Generate traffic (best-effort) and check logs:

  $ R 'nc -z -w1 127.0.0.1 65531 2>/dev/null || true; sleep 2; if command -v logread >/dev/null 2>&1; then logread | grep -F "${LP}" | tail -n 1 | sed "s/[[:space:]]\\+/ /g"; else dmesg | grep -F "${LP}" | tail -n 1 | sed "s/[[:space:]]\\+/ /g"; fi || true'
  *CRAM_IPT_LOG_* (glob)

Cleanup:

  $ R 'iptables -D INPUT -p tcp --dport 65531 -j LOG --log-prefix "${LP} " --log-level 4 2>/dev/null || true; echo "Cleaned LOG rule"'
  Cleaned LOG rule
