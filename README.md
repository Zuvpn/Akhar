# Akhar (FAST Bootstrap)

این نسخه برای اینکه منتظر نصب gcc/build-essential و کامپایل SoftEther نمونی ساخته شده.

✅ SoftEther از **APT** نصب می‌شود (پکیج‌های `softether-vpnserver` و `softether-vpnclient`).

## نصب
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Zuvpn/Akhar/main/install.sh)
sudo Akhar --bootstrap
```

## اگر پکیج پیدا نشد
Universe را فعال کن:
```bash
sudo add-apt-repository universe -y
sudo apt update
```

