# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Inter-LAN isolation example with ACCEPT exception (temporary)
# Notes:
#  - Skip-safe if insufficient LAN interfaces. Deterministic verification and cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Discover two distinct LAN interfaces (skip-safe if less than two):

  $ R 'LANS="$(ip -o link show 2>/dev/null | awk -F\": \" \"/\\blan[1-9]\\b|\\bbr-lan\\b|\\bbr-lan\\.[0-9]+/{print $2}\" | head -n 3)"; LAN_A="$(echo \"$LANS\" | sed -n \"1p\")"; LAN_B="$(echo \"$LANS\" | sed -n \"2p\")"; [ -n \"$LAN_A\" ] && [ -n \"$LAN_B\" ] || { echo insufficient-lan-if; exit 0; }; echo "$LAN_A $LAN_B" | sed "s/[[:alnum:]-]\\+/<IF> /g"'
  <IF> <IF> (glob)

Insert DROP and ACCEPT exception (tcp/53):

  $ R 'iptables -I FORWARD 1 -i "$LAN_A" -o "$LAN_B" -j DROP; iptables -I FORWARD 1 -i "$LAN_A" -o "$LAN_B" -p tcp --dport 53 -j ACCEPT; echo added'
  added

Verify ACCEPT exception:

  $ R 'iptables-save | grep -E "^-A FORWARD .* -i ${LAN_A} .* -o ${LAN_B} .* -p tcp .* --dport 53 .* -j ACCEPT" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A FORWARD * -i * -o * -p tcp * --dport 53 * -j ACCEPT

Verify DROP isolation:

  $ R 'iptables-save | grep -E "^-A FORWARD .* -i ${LAN_A} .* -o ${LAN_B} .* -j DROP" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A FORWARD * -i * -o * -j DROP

Cleanup:

  $ R 'iptables -D FORWARD -i "$LAN_A" -o "$LAN_B" -p tcp --dport 53 -j ACCEPT 2>/dev/null || true; iptables -D FORWARD -i "$LAN_A" -o "$LAN_B" -j DROP 2>/dev/null || true; echo "Cleaned inter-LAN isolation rules $LAN_A->$LAN_B"'
  Cleaned inter-LAN isolation rules * (glob)
