#!/usr/bin/env bash
set -Eeuo pipefail
REPO_RAW="https://raw.githubusercontent.com/Zuvpn/Akhar/main"

sudo apt update
sudo apt install -y curl nftables nginx

sudo curl -fsSL "$REPO_RAW/Akhar" -o /usr/local/bin/Akhar
sudo chmod +x /usr/local/bin/Akhar

echo "✅ Akhar installed."
echo "Next: sudo Akhar --bootstrap"
