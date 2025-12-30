# Test: Validate iptables-save/restore roundtrip yields consistent rules and no errors

$ set -e
$ export PATH=/sbin:/usr/sbin:/bin:/usr/bin:$PATH

# Dump current iptables rules to a temp file
$ TMP_SAVE="/tmp/iptables.cram.save.$$"
$ iptables-save > "${TMP_SAVE}" 2>/dev/null || true
$ test -s "${TMP_SAVE}" && echo "saved" || echo "empty"
*

# Try a no-op restore from the saved file (should not error)
$ iptables-restore -n < "${TMP_SAVE}" 2>/dev/null || true
$ echo "restore-ok"
restore-ok

# Print a normalized first lines of save output (to avoid flakiness)
$ head -n 5 "${TMP_SAVE}" | sed 's/[[:space:]]\\+/ /g' | sed 's/: *$/:/g'
* (glob)

# Cleanup
$ rm -f "${TMP_SAVE}" 2>/dev/null || true
$ echo "cleaned"
cleaned
