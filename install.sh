#!/usr/bin/env bash
set -Eeuo pipefail

apt update
apt install -y curl nftables nginx tar

install -m 755 Akhar /usr/local/bin/Akhar

echo "✅ Akhar installed."
echo "Next:"
echo "  sudo Akhar --bootstrap"
