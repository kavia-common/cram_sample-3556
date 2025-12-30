# Reference: sample_case/02-sample2.t for format and conventions
# Purpose: Hairpin NAT scenario validation (temporary)
# Notes:
#  - Skip-safe if br-lan missing. Deterministic verification and cleanup.

Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Detect br-lan (skip-safe):

  $ R 'LAN_BR="$(ip -o link show | awk -F\": \" \"/\\bbr-lan\\b/{print $2; exit}\")"; [ -n \"$LAN_BR\" ] || { echo br-lan-missing; exit 0; }; echo \"$LAN_BR\" | sed \"s/.*/<BR-LAN>/\"'
  <BR-LAN>

Use RFC5737 DNAT target:

  $ R 'DNAT_IP="192.0.2.50"; WAN_PORT="65020"; LAN_PORT="80"; echo ok'
  ok

Insert DNAT and MASQUERADE:

  $ R 'iptables -t nat -I PREROUTING 1 -i "$LAN_BR" -p tcp --dport ${WAN_PORT} -j DNAT --to-destination ${DNAT_IP}:${LAN_PORT}; iptables -t nat -I POSTROUTING 1 -o "$LAN_BR" -d ${DNAT_IP} -p tcp --dport ${LAN_PORT} -j MASQUERADE; echo added'
  added

Verify PREROUTING DNAT:

  $ R 'iptables-save -t nat | grep -E "^-A PREROUTING .* -i ${LAN_BR} .* -p tcp .* --dport ${WAN_PORT} .* -j DNAT .*to:${DNAT_IP}:${LAN_PORT}" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A PREROUTING * -i * -p tcp * --dport * -j DNAT *to:* (glob)

Verify POSTROUTING MASQUERADE:

  $ R 'iptables-save -t nat | grep -E "^-A POSTROUTING .* -o ${LAN_BR} .* -d ${DNAT_IP} .* -p tcp .* --dport ${LAN_PORT} .* -j (SNAT|MASQUERADE)" | sed "s/[[:space:]]\\+/ /g" | head -n 1'
  -A POSTROUTING * -o * -d * -p tcp * --dport * -j * (glob)

Cleanup:

  $ R 'iptables -t nat -D POSTROUTING -o "$LAN_BR" -d ${DNAT_IP} -p tcp --dport ${LAN_PORT} -j MASQUERADE 2>/dev/null || true; iptables -t nat -D PREROUTING -i "$LAN_BR" -p tcp --dport ${WAN_PORT} -j DNAT --to-destination ${DNAT_IP}:${LAN_PORT} 2>/dev/null || true; echo "Cleaned hairpin NAT example"'
  Cleaned hairpin NAT example
