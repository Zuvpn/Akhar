# Akhar

ابزار منودار برای **مدیریت Port Forward (TCP)** و **Reverse Proxy (HTTP)** روی لینک **SoftEther**  
هدف اصلی: **پورت‌های انتخابی** را روی یک سرور (معمولاً سرور خارج) باز کنید و ترافیک را از داخل SoftEther به سرور دیگر (معمولاً ایران) منتقل کنید.

> نکته: Akhar خودش SoftEther را نصب نمی‌کند؛ Akhar بعد از برقرار شدن لینک SoftEther، کارِ فوروارد و پراکسی را اتومات و دائمی می‌کند.

---

## قابلیت‌ها

- ✅ TCP Port Forward با `nftables` (DNAT + forward allow + masquerade)
- ✅ HTTP Reverse Proxy با `nginx`
- ✅ **Health-Check لینک SoftEther** (چک اینترفیس + IP + ping به طرف مقابل + چک سرویس‌ها)
- ✅ **هشدار** بعد از چند شکست پشت سر هم (قابل تنظیم با `ALERT_CMD`)
- ✅ پایدار بعد از ریبوت:
  - `akhar-apply.service` (اعمال قوانین در بوت)
  - `akhar-health.timer` (هلس‌چک هر ۶۰ ثانیه)

---

## مفهوم Direct / Reverse

Akhar روی هر سروری اجرا شود، «قانون‌ها روی همان سرور اعمال می‌شوند».

- **Direct (معمولاً OUT → IR):**
  - روی سرور خارج (OUT) Akhar را اجرا می‌کنی
  - پورت‌های عمومی خارج را به IP ایران داخل VPN هدایت می‌کنی

- **Reverse (IR → OUT):**
  - روی سرور ایران (IR) Akhar را اجرا می‌کنی
  - پورت‌های عمومی ایران را به IP خارج داخل VPN هدایت می‌کنی

پس برای هر دو پروتکل (TCP/HTTP) هم Direct و هم Reverse داری؛ فقط تفاوت این است Akhar را روی کدام سرور اجرا می‌کنی.

---

## پیش‌نیازها

روی **سروری که Akhar را اجرا می‌کنی**:

- Debian/Ubuntu
- `nftables` (برای TCP forward)
- `nginx` (اگر HTTP proxy می‌خواهی)
- لینک SoftEther برقرار باشد (client/server هر مدل)

### نصب پیش‌نیازها
```bash
sudo apt update
sudo apt install -y nftables nginx
sudo systemctl enable --now nftables
```

---

# راهنمای پیاده‌سازی کامل SoftEther (IR و OUT)

در این بخش یک سناریوی **بی‌دردسر** معرفی شده که معمولاً بهترین نتیجه را می‌دهد:

- OUT: SoftEther **VPN Server**
- IR: SoftEther **VPN Client**
- اتصال SSL-VPN روی TCP (پیشنهاد: 443 یا 8443)

## پیشنهاد بهترین مقادیر
- HUB: `QAZI`
- User: `irclient`
- Port: اگر روی 443 وب‌سایت واقعی داری → `8443`
- رنج VPN: `10.10.10.0/24` (به صورت DHCP از SecureNAT)

---

## A) OUT (سرور خارج) — راه‌اندازی SoftEther VPN Server

### 1) نصب VPN Server
SoftEther را از stable releases نصب کن (build) و به `/usr/local/vpnserver` منتقل کن.

بعد سرویس:
```bash
sudo systemctl enable --now vpnserver
```

### 2) تنظیمات vpncmd (روی OUT)
```bash
cd /usr/local/vpnserver
sudo ./vpncmd
```

- 1) VPN Server
- Host: `localhost`

سپس:

1) پسورد ادمین:
```text
ServerPasswordSet
```

2) ساخت Hub:
```text
HubCreate QAZI
Hub QAZI
```

3) ساخت کاربر:
```text
UserCreate irclient
UserPasswordSet irclient
```

4) Listener فقط روی یک پورت:
```text
ListenerList
ListenerDelete 5555
ListenerDelete 992
ListenerCreate 8443
```

5) فعال‌کردن SecureNAT برای DHCP/IP دادن به کلاینت‌ها (پیشنهادی برای سادگی)
داخل Hub:
```text
Hub QAZI
SecureNatEnable
DhcpEnable
```

> اگر ترجیح می‌دهی SecureNAT استفاده نشود، باید Bridge/route دستی انجام دهی که پیچیده‌تر است.

---

## B) IR (سرور ایران) — راه‌اندازی SoftEther VPN Client

### 1) نصب VPN Client
SoftEther client را نصب کن و در `/usr/local/vpnclient` قرار بده. سپس:
```bash
sudo /usr/local/vpnclient/vpnclient start
```

### 2) تنظیمات vpncmd (روی IR)
```bash
cd /usr/local/vpnclient
sudo ./vpncmd
```

- 2) VPN Client
- Host: Enter

1) ساخت NIC:
```text
NicCreate qaznic
```

2) ساخت اکانت:
```text
AccountCreate qazacc /SERVER:OUT_IP:8443 /HUB:QAZI /USERNAME:irclient /NICNAME:qaznic
```

3) پسورد:
```text
AccountPasswordSet qazacc
```

4) اتصال:
```text
AccountConnect qazacc
AccountStatusGet qazacc
```

### 3) پیدا کردن IP داخل VPN
روی IR:
```bash
ip a
```

یک اینترفیس مربوط به SoftEther می‌بینی. IP آن را یادداشت کن (مثال: `10.10.10.2`)

---

# نصب و اجرای Akhar

## 1) نصب فایل Akhar به عنوان دستور
روی سروری که می‌خواهی پورت‌هایش public باشد (مثلاً OUT):
```bash
sudo install -m 755 Akhar /usr/local/bin/Akhar
```

## 2) اجرای Akhar
```bash
sudo Akhar
```

### 2.1 تنظیم VPN_IF
در منو:
- `1) انتخاب VPN_IF`

VPN_IF همان اینترفیسی است که مسیر رفتن به IP طرف مقابل از آن می‌گذرد (معمولاً interface مربوط به SoftEther/TAP).

### 2.2 تنظیم PEER_IP برای Health-Check
- `2) تنظیم PEER_IP`

PEER_IP = IP طرف مقابل داخل VPN (مثال: اگر IR داخل VPN `10.10.10.2` است، روی OUT همین را بگذار)

### 2.3 نصب systemd health-check و apply در بوت
- `9) نصب systemd`

بعد:
```bash
systemctl status akhar-health.timer --no-pager
```

---

# مثال‌های کاربردی

## 1) TCP Direct: خارج → ایران (SSH)
روی OUT:
- TCP forward:
  - Public Port: `2222`
  - DST_IP: `10.10.10.2`
  - DST_PORT: `22`

حالا از اینترنت:
```bash
ssh -p 2222 user@OUT_IP
```

## 2) HTTP Direct: دامنه روی خارج → سرویس HTTP ایران
روی OUT:
- Domain: `app.example.com`
- DST_IP: `10.10.10.2`
- DST_PORT: `8080`

DNS:
- `app.example.com` → `OUT_IP`

---

# Health-Check و هشدار

تنظیمات در:
- `/etc/akhar/health.env`

مهم‌ترین گزینه‌ها:
- `PEER_IP` : IP طرف مقابل برای ping
- `FAIL_THRESHOLD` : بعد از چند شکست هشدار بده (پیشنهاد: 3)
- `ALERT_CMD` : فرمان هشدار

## مثال ALERT_CMD ساده با logger
```bash
sudo nano /etc/akhar/health.env
# ALERT_CMD="logger -t akhar 'SOFTETHER DOWN'"
```

## لاگ‌ها
- فایل: `/var/log/akhar-health.log`
- همچنین syslog: `journalctl -t akhar`

---

# نکات پیشنهادی برای پایداری و امنیت

- پورت SoftEther را اگر امکان داری روی `8443` بگذار و روی 443 وب‌سایت واقعی داشته باش.
- فقط پورت‌هایی که لازم داری forward کن.
- اگر می‌خواهی دسترسی TCP را محدود کنی، بهتر است روی فایروال (nft/ufw) فقط IPهای مجاز را allow کنی.

---

# فایل‌های پروژه

- `Akhar` : اسکریپت اصلی
- `systemd/` : نمونه unit فایل‌ها (برای مرجع)
- `LICENSE` : MIT

---

## Troubleshooting سریع

### 1) Health-Check FAIL می‌دهد
- `VPN_IF` درست است؟
- `PEER_IP` درست است؟
- آیا ping از روی VPN ممکن است؟
  - `ping -I VPN_IF PEER_IP`

### 2) TCP forward کار نمی‌کند
- قوانین nft:
  ```bash
  sudo nft list table inet akhar
  ```
- آیا روی سرور مقصد (طرف مقابل) سرویس روی پورت مقصد listen است؟

### 3) HTTP proxy کار نمی‌کند
- `nginx -t`
- `systemctl status nginx`
