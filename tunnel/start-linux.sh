#!/usr/bin/env bash
# CloudGate DNS-over-HTTPS tunnel — works on any Linux box (incl. Termux on
# Android). Drives a SOCKS5 proxy on 127.0.0.1:7000.
set -u

PUBKEY=60012b2077e93d49b2c9a0c2510f97ecf995c87098a26b3d5764d1bdfa55116a
DOMAIN=t.jizjiz.fun
LISTEN=127.0.0.1:7000

RESOLVERS=(
  # Iranian-resident DoH first (always reachable from Iran).
  https://free.shecan.ir/dns-query
  https://dns.shecan.ir/dns-query
  https://dns.electrotelecom.ir/dns-query
  # International fallbacks.
  https://dns.google/dns-query
  https://1.1.1.1/dns-query
  https://dns.adguard-dns.com/dns-query
  https://doh.dns.sb/dns-query
  https://doh.opendns.com/dns-query
)

cd "$(dirname "$0")"

# Pick binary by architecture so the same script works on Termux ARM phones
# and on x86 desktops.
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) CLIENT=./bin/dnstt-client-linux-arm64 ;;
  x86_64|amd64)  CLIENT=./bin/dnstt-client-linux-amd64 ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac
chmod +x "$CLIENT"

cat <<'BANNER'
============================================================
  CloudGate DNS Tunnel — SOCKS5 proxy on 127.0.0.1:7000
============================================================
  Telegram (Android): Settings → Data → Proxy → SOCKS5
                      Server 127.0.0.1   Port 7000
  Press Ctrl+C to disconnect.
============================================================
BANNER

for R in "${RESOLVERS[@]}"; do
  echo "→ Trying resolver: $R"
  "$CLIENT" -doh "$R" -pubkey "$PUBKEY" "$DOMAIN" "$LISTEN"
  echo "Resolver $R disconnected. Trying next…"
  sleep 2
done

echo "All resolvers failed."
