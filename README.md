# CloudGate Scan

A static, in-browser Cloudflare clean-IP scanner that **runs on the user's
device**, so the measurements come from the user's real ISP — critical in
regions where IP cleanness is location-dependent (Iran national internet, etc).

Served from GitHub Pages because `*.github.io` is reliably reachable on
networks that block Cloudflare-hosted domains.

## Usage

Open: <https://hesamhadadi.github.io/cloudgate-scan/>

Paste your `vless://...` link, press "شروع اسکن", wait 10-20 seconds, copy the
winning link with one click.

Winners are anonymously reported back to the CloudGate worker so the panel can
rotate in currently-working IPs for every user.

## Develop

Edit `index.html` — it's self-contained (no build step).
