#!/usr/bin/env bash
# CloudGate DNS-over-HTTPS tunnel — drives a SOCKS5 proxy on 127.0.0.1:7000.
# Cycles through DoH resolvers; the first one your network allows wins.
set -u

PUBKEY=60012b2077e93d49b2c9a0c2510f97ecf995c87098a26b3d5764d1bdfa55116a
DOMAIN=t.jizjiz.fun
LISTEN=127.0.0.1:7000

RESOLVERS=(
  # Iranian-resident DoH first — guaranteed reachable inside Iran. Whether
  # they can recurse to our auth NS in DE depends on their upstream peering;
  # often yes for general queries.
  https://free.shecan.ir/dns-query
  https://dns.shecan.ir/dns-query
  https://dns.electrotelecom.ir/dns-query
  # International DoH fallbacks.
  https://dns.google/dns-query
  https://1.1.1.1/dns-query
  https://dns.adguard-dns.com/dns-query
  https://doh.dns.sb/dns-query
  https://doh.opendns.com/dns-query
)

cd "$(dirname "$0")"

# Pick the right binary for this Mac.
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  CLIENT=./bin/dnstt-client-darwin-arm64
else
  CLIENT=./bin/dnstt-client-darwin-amd64
fi
chmod +x "$CLIENT" 2>/dev/null

# macOS Gatekeeper will quarantine unsigned binaries; clear it.
xattr -d com.apple.quarantine "$CLIENT" 2>/dev/null || true

cat <<'BANNER'
============================================================
  CloudGate DNS Tunnel — SOCKS5 proxy on 127.0.0.1:7000
============================================================

  Telegram (Desktop):
    Settings → Advanced → Connection type → Use custom proxy
    Type: SOCKS5   Hostname: 127.0.0.1   Port: 7000

  Firefox:
    Settings → Network Settings → Manual proxy
    SOCKS Host: 127.0.0.1   Port: 7000   SOCKS v5
    ☑ Proxy DNS when using SOCKS v5

  Press Ctrl+C to disconnect.
============================================================

BANNER

for R in "${RESOLVERS[@]}"; do
  echo "→ Trying resolver: $R"
  "$CLIENT" -doh "$R" -pubkey "$PUBKEY" "$DOMAIN" "$LISTEN"
  ec=$?
  echo
  echo "Resolver $R disconnected (exit $ec). Trying next…"
  sleep 2
done

echo "All resolvers failed."
read -rp "Press Enter to close…" _
