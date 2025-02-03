# 🛡️ HIDS Monitor for Raspberry Pi & OpenWrt

🚀 A lightweight Host-Based Intrusion Detection System (HIDS) built with Ruby + Sinatra for Raspberry Pi and OpenWrt. Monitors system logs for suspicious activity and alerts administrators in real time.

---

## 📋 Features
✅ Monitors `/var/log/auth.log` for SSH brute-force attacks  
✅ Logs activity and generates alerts via HTTP API  
✅ Works on Raspberry and OpenWrt (future support)  
✅ Can be extended with Telegram notifications  
✅ Planned: Visualizing attack data (graphs, dashboards)  

---

## 🛠️ Installation & Setup

### 1️⃣ Install Dependencies
```bash
sudo apt update && sudo apt install ruby-full
```
Install required gems:
```bash
gem install bundler sinatra
```

### 2️⃣ Clone the repository
```bash
git clone https://github.com/v3rb4/hids-monitor.git
cd hids-monitor
```

### 3️⃣ Start the HIDS Server
```bash
ruby hids.rb
```
➡ Open in browser: [http://localhost:4567](http://localhost:4567)

### 4️⃣ Start the Log Monitoring Script
```bash
ruby log_monitor.rb
```

---

## 📂 Example Logs
```plaintext
🚨 ALERT: Unauthorized SSH login attempt detected!
IP: 192.168.1.100
User: root
Time: 2024-02-02 12:45:00
Log: "Failed password for root from 192.168.1.100 port 54321 ssh2"
```

---

## ❗ Troubleshooting
### 🔹 SSH brute-force attempts are not logged
If running `sudo tail -f /var/log/auth.log` does not show SSH login attempts:
1. **Check if `rsyslog` is installed and running:**
   ```bash
   sudo systemctl status rsyslog
   ```
   If inactive, enable and start it:
   ```bash
   sudo apt install rsyslog -y
   sudo systemctl enable --now rsyslog
   ```

2. **Ensure SSH logs are written to `/var/log/auth.log`**
   ```bash
   sudo grep "auth" /etc/rsyslog.conf
   ```
   If the following line is commented out, uncomment it:
   ```
   auth,authpriv.*    /var/log/auth.log
   ```
   Restart rsyslog:
   ```bash
   sudo systemctl restart rsyslog
   ```

3. **If logs are stored in `journalctl`, check logs there:**
   ```bash
   sudo journalctl -u ssh --no-pager | tail -n 20
   ```

4. **Test logging manually:**
   ```bash
   echo "Feb 03 14:22:10 raspberrypi sshd[3245]: Failed password for root from 192.168.1.50 port 54567 ssh2" | sudo tee -a /var/log/auth.log
   ```
   If `log_monitor.rb` does not detect this, check its execution.

---

## 📌 TODO / Future Enhancements
✅ Expand log analysis (not just `/var/log/auth.log`)  
✅ Telegram & Slack notifications  
✅ Web dashboard with attack statistics (graphs, tables)  
✅ Integration with AbuseIPDB for threat intelligence  
✅ Support for OpenWrt (lightweight deployment)  
✅ False positive detection system  
✅ Database for logging attacks  
✅ Whitelist trusted IPs to reduce noise  

---

## 🔧 Configurations
Modify `hids.rb` and `log_monitor.rb` to change:
| Setting | Default | Description |
|---------|---------|-------------|
| `ALERT_THRESHOLD` | 5 | Number of failed attempts before triggering alert |
| `LOG_FILE` | `/var/log/auth.log` | Path to the monitored log file |
| `TELEGRAM_BOT_TOKEN` | `nil` | Token for Telegram bot (if enabled) |
| `TELEGRAM_CHAT_ID` | `nil` | Chat ID for receiving alerts |

---

## 📜 License
This project is released under the **Creative Commons Zero (CC0) License** – completely free to use and modify.


