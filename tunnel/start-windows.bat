@echo off
chcp 65001 >nul
title CloudGate Tunnel (DNS over HTTPS)

REM ============================================================================
REM CloudGate DNS-over-HTTPS tunnel — drives a SOCKS5 proxy on 127.0.0.1:7000
REM that survives when direct TCP to the VPS is blocked, by piggy-backing on
REM whatever DoH resolver still works from the user's network.
REM ============================================================================

set PUBKEY=60012b2077e93d49b2c9a0c2510f97ecf995c87098a26b3d5764d1bdfa55116a
set DOMAIN=t.jizjiz.fun
set LISTEN=127.0.0.1:7000

REM Try resolvers in order until one connects. dns.google is almost always open
REM in Iran since blocking it would break too many other apps.
REM Iranian-friendly DoH first (always reachable from inside Iran),
REM then international fallbacks. The first one whose outbound recursive
REM path can reach our auth NS wins.
set RESOLVERS=https://free.shecan.ir/dns-query https://dns.shecan.ir/dns-query https://dns.electrotelecom.ir/dns-query https://dns.google/dns-query https://1.1.1.1/dns-query https://dns.adguard-dns.com/dns-query https://doh.dns.sb/dns-query https://doh.opendns.com/dns-query

cd /d "%~dp0"

if exist bin\dnstt-client-windows-arm64.exe if not "%PROCESSOR_ARCHITECTURE%"=="ARM64" goto x64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set CLIENT=bin\dnstt-client-windows-arm64.exe
    goto run
)
:x64
set CLIENT=bin\dnstt-client-windows-amd64.exe

:run
echo.
echo ============================================================
echo   CloudGate DNS Tunnel — SOCKS5 proxy on 127.0.0.1:7000
echo ============================================================
echo.
echo   Telegram: Settings -^> Advanced -^> Proxy
echo            Add SOCKS5 -^> Server: 127.0.0.1  Port: 7000
echo.
echo   Firefox:  Settings -^> Network -^> Manual proxy -^> SOCKS5 127.0.0.1:7000
echo            (also tick "Proxy DNS when using SOCKS v5")
echo.
echo   Press Ctrl+C to disconnect.
echo ============================================================
echo.

for %%R in (%RESOLVERS%) do (
    echo Trying resolver: %%R
    "%CLIENT%" -doh %%R -pubkey %PUBKEY% %DOMAIN% %LISTEN%
    echo.
    echo Resolver %%R failed or disconnected. Trying next...
    timeout /t 2 >nul
)

echo.
echo All resolvers failed. Check your internet connection.
pause
