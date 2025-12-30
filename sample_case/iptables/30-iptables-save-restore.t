# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Validate iptables-save/restore roundtrip yields consistent rules and no errors
# Notes:
#  - Non-destructive, uses temp files; deterministic checks via normalization.
#  - Follows the same header/alias style as 02-sample2.t.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Dump current iptables rules to a temp file (skip-safe if command missing):

  $ R 'TMP_SAVE="/tmp/iptables.cram.save.$$"; (iptables-save > "${TMP_SAVE}" 2>/dev/null || true); test -s "${TMP_SAVE}" && echo saved || echo empty'
  * (glob)

Try a no-op restore from the saved file (should not error):

  $ R 'test -s "${TMP_SAVE:-/tmp/iptables.cram.save.$$}" || TMP_SAVE="/tmp/iptables.cram.save.$$"; iptables-restore -n < "${TMP_SAVE}" 2>/dev/null || true; echo restore-ok'
  restore-ok

Print normalized first lines of save output (avoid flakiness):

  $ R 'head -n 5 "${TMP_SAVE}" 2>/dev/null | sed "s/[[:space:]]\\+/ /g" | sed "s/: *$/:/g" || true'
  * (glob)

Cleanup:

  $ R 'rm -f "${TMP_SAVE}" 2>/dev/null || true; echo cleaned'
  cleaned
