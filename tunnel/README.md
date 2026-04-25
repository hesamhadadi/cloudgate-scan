# CloudGate DNS Tunnel

یه تونل که از طریق **DNS-over-HTTPS** کار می‌کنه. 

**چرا این روش مهمه؟** اپراتورهای ایرانی IP سرور خارجی رو null-route می‌کنن (هیچ پورتی باز نیست). ولی همه‌شون باید DNS و HTTPS رو باز نگه دارن وگرنه نت ملی هم نمی‌تونه کار کنه. این تونل ترافیک رو داخل DNS query رمز می‌کنه و از یه resolver عمومی (Google, Cloudflare, AdGuard) عبور می‌ده.

```
[Telegram]
    ↓ SOCKS5 127.0.0.1:7000
[dnstt-client روی دستگاه شما]
    ↓ HTTPS (port 443)
[dns.google یا 1.1.1.1]    ← این مسیر رو ایران هیچ‌وقت نمی‌بنده
    ↓ recursive DNS
[سرور ما در آلمان]
    ↓
[اینترنت آزاد]
```

## ⚡ راه‌اندازی سریع

### Windows
1. فایل `start-windows.bat` رو دابل‌کلیک کن
2. می‌گه «SOCKS5 proxy on 127.0.0.1:7000» — همینه
3. تو **Telegram Desktop**:
   - Settings → Advanced → Connection type → **Use custom proxy**
   - Type: **SOCKS5** | Hostname: **127.0.0.1** | Port: **7000**
4. وصل میشه ✓

### macOS
1. فایل `start-mac.command` رو دابل‌کلیک کن (اگه گفت «cannot be opened»: راست‌کلیک → Open)
2. مثل Windows کانفیگ Telegram

### اندروید (Termux)
1. اپ **Termux** رو از F-Droid یا Google Play نصب کن
2. این فایل‌ها رو از طریق USB یا فایل‌منیجر کپی کن به `/sdcard/tunnel/`
3. تو Termux:
   ```bash
   cd /sdcard/tunnel
   bash start-linux.sh
   ```
4. تو Telegram اندروید: **Settings → Data and Storage → Proxy Settings → Add Proxy → SOCKS5**
   - Server: `127.0.0.1` | Port: `7000`

### Linux (دسکتاپ)
```bash
chmod +x start-linux.sh
./start-linux.sh
```

## 🔧 کانفیگ مرورگرها

### Firefox
1. Settings → Network Settings → **Manual proxy configuration**
2. SOCKS Host: `127.0.0.1` Port: `7000` — **SOCKS v5**
3. ☑ **Proxy DNS when using SOCKS v5**

### Chrome / Edge (با extension)
- نصب «**FoxyProxy**» یا «**Proxy SwitchyOmega**»
- پروفایل جدید: SOCKS5، 127.0.0.1، 7000

### کل سیستم (macOS)
System Settings → Network → ادپتور فعال → Details → Proxies → SOCKS Proxy
Server: 127.0.0.1, Port: 7000

## 🌐 اگه یه Resolver کار نکرد

اسکریپت‌ها به ترتیب این resolverها رو امتحان می‌کنن:

1. `dns.google` (گوگل)
2. `1.1.1.1` (Cloudflare)
3. `dns.adguard-dns.com`
4. `doh.dns.sb`
5. `doh.opendns.com`

اگه همه‌شون رو نت تو بسته‌ست (بعید)، این Resolverها رو هم می‌تونی تو فایل اسکریپت دستی اضافه کنی:

| Resolver | URL |
|---|---|
| Mullvad | `https://doh.mullvad.net/dns-query` |
| Quad9 | `https://dns.quad9.net/dns-query` |
| NextDNS | `https://dns.nextdns.io/[شناسه‌ی شما]/dns-query` |
| LibreDNS | `https://doh.libredns.gr/dns-query` |
| Shecan ایران | `https://free.shecan.ir/dns-query` |

## ⚠️ نکته‌ها

- **سرعت پایین**: DNS-tunnel ذاتاً کند است (~۵۰-۲۰۰KB/s). برای پیامک، چت، load سبک خوبه. ویدیو نه.
- **MTU**: اگه قطعی داشتی، توی فایل اسکریپت `LISTEN` رو نگه‌دار، فقط resolver رو عوض کن.
- **همزمان نمی‌تونی روی یه دستگاه دو تا instance از این تونل اجرا کنی** (پورت 7000).
- **اگه پورت 7000 درگیره**، توی اسکریپت `127.0.0.1:7000` رو به `127.0.0.1:7100` (یا هرچی) عوض کن، تو Telegram هم همون رو بذار.

## 🆘 Troubleshooting

| مشکل | راه‌حل |
|---|---|
| Mac می‌گه "cannot be opened" | راست‌کلیک → Open → Open |
| Windows Defender هشدار میده | Allow؛ binary unsigned هست ولی open-source build شده |
| Telegram وصل نمیشه ولی browser میشه | تو Telegram «Try other sockets» رو تیک نزنی |
| Termux: permission denied | `termux-setup-storage` رو اول اجرا کن |
| اصلاً وصل نمیشه | resolverها همه بسته‌اند — یا VPN دیگه‌ای فعال داری که جلو DNS رو می‌گیره |

ساخته‌شده با [dnstt](https://www.bamsoftware.com/software/dnstt/) از David Fifield.
