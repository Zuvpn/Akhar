# Akhar (Full Bootstrap)

Akhar یک ابزار منودار برای راه‌اندازی لینک SoftEther و مدیریت انتقال ترافیک بین دو سرور است:

- ✅ **Bootstrap فول**: نصب و کانفیگ SoftEther (Server/Client)
- ✅ TCP Port Forward با `nftables` (DNAT + forward allow + masquerade)
- ✅ HTTP Reverse Proxy با `nginx`
- ✅ Health-check + هشدار + timer systemd

> Akhar روی هر سروری اجرا شود، قوانین روی همان سرور اعمال می‌شوند.  
پس هم Direct و هم Reverse برای TCP/HTTP قابل انجام است.

---

## نصب سریع (روی هر دو سرور)

بعد از آپلود فایل‌ها در ریپوی خودت:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Zuvpn/Akhar/main/install.sh)
```

سپس:

```bash
sudo Akhar --bootstrap
```

---

## Bootstrap چه چیزهایی می‌پرسد؟

1) نقش این سرور: `IR` یا `OUT`  
2) IP عمومی سرور مقابل  
3) پورت SoftEther (پیشنهاد: `8443`)  
4) HUB/USER (پیشنهاد: `QAZI` و `irclient`)  
5) پسوردها (اگر خالی بگذاری خودش امن تولید می‌کند)  
6) انتخاب `VPN_IF` (اینترفیس tap/vpn روی همین سرور)  
7) `PEER_IP` داخل VPN برای Health-check  
8) پنل x-ui روی کدام سرور است (LOCAL/PEER/NONE) + ساخت forward اختیاری  
9) قوانین TCP و HTTP به صورت لیستی

---

## مقادیر پیشنهادی

- SoftEther Port: `8443`
- HUB: `QAZI`
- USER: `irclient`
- Health:
  - `FAIL_THRESHOLD=3`
  - `PING_TIMEOUT=1`
- Port پنل x-ui (اگر نیاز شد): `54321`
- Public port برای فوروارد پنل: `15432`

---

## فرمت قوانین در Bootstrap

### TCP
`public_port:dst_ip:dst_port`  
مثال:
`2222:10.10.10.2:22`

### HTTP
`domain:dst_ip:dst_port`  
مثال:
`app.example.com:10.10.10.2:8080`

---

## بعد از نصب

### وضعیت سرویس‌ها
روی OUT:
```bash
systemctl status vpnserver --no-pager
```

روی IR:
```bash
systemctl status vpnclient --no-pager
```

### مشاهده قوانین فوروارد
```bash
sudo nft list table inet akhar
```

### وضعیت Health timer
```bash
systemctl status akhar-health.timer --no-pager
tail -n 50 /var/log/akhar-health.log
```

---

## نکات

- اگر روی OUT پورت 443 را برای وب‌سایت واقعی می‌خواهی، SoftEther را روی `8443` بگذار.
- فایل وضعیت و پسوردها در `/etc/akhar/state.env` با مجوز 600 ذخیره می‌شود.
- اگر VPN_IF را موقع Bootstrap انتخاب نکردی، از منو «انتخاب VPN_IF» انجام بده و بعد «اعمال مجدد» را بزن.

