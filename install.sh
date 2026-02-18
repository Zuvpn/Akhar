#!/usr/bin/env bash
set -Eeuo pipefail

[[ "${EUID:-$(id -u)}" -eq 0 ]] || { echo "Run as root: sudo ./install.sh"; exit 1; }

apt update
apt install -y nftables nginx

install -m 755 Akhar /usr/local/bin/Akhar

mkdir -p /etc/akhar/forwards.d /etc/akhar/nginx.d
chmod 700 /etc/akhar /etc/akhar/forwards.d /etc/akhar/nginx.d || true

# Create default configs if missing
/usr/local/bin/Akhar --install-units >/dev/null 2>&1 || true

echo "✅ Installed Akhar."
echo "Next:"
echo "  1) Run: sudo Akhar"
echo "  2) Set VPN_IF and PEER_IP"
echo "  3) Add TCP/HTTP rules"
