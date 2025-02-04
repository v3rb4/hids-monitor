🛡️ **HIDS Monitor for Raspberry Pi & OpenWrt**

A lightweight Host-Based Intrusion Detection System (HIDS) built with Ruby + Sinatra for Raspberry Pi and OpenWrt. Monitors system logs for suspicious activity and sends real-time alerts via Telegram.

---

## 📋 Features
✅ Real-time Telegram notifications for SSH brute-force attacks  
✅ Time window-based attack detection algorithm  
✅ Monitors `/var/log/auth.log` for suspicious activity  
✅ RESTful API for logging and alerts  
✅ Works on Raspberry Pi and OpenWrt (future support)  
✅ **Planned:** Attack visualization dashboard  

---

## 🛠️ Installation & Setup

### 1️⃣ Install Dependencies
```bash
sudo apt update && sudo apt install ruby-full
```
```bash
gem install bundler sinatra telegram-bot-ruby
```

### 2️⃣ Clone the repository
```bash
git clone https://github.com/v3rb4/hids-monitor.git
cd hids-monitor
```

### 3️⃣ Configure Telegram Notifications

#### Create a Telegram bot:
1. Message `@BotFather` on Telegram
2. Use `/newbot` command
3. Save the provided token

#### Get your Chat ID:
1. Send a message to your bot
2. Visit: `https://api.telegram.org/bot<YourBOTToken>/getUpdates`
3. Find your `chat_id` in the response

#### Update configuration:
Edit `server.rb`:
```ruby
TELEGRAM_BOT_TOKEN = 'YOUR_BOT_TOKEN'
TELEGRAM_CHAT_ID = 'YOUR_CHAT_ID'
```

### 4️⃣ Start the HIDS Server
```bash
ruby server.rb
```
➡ Open in browser: `http://localhost:4567`

### 5️⃣ Start the Log Monitor
```bash
ruby log_monitor.rb
```

---

## 📂 Example Alert
```
🚨 HIDS Alert!
Brute-force attack detected!
IP: 192.168.1.100
Attempts: 5 in last 5 minutes
```

---

## 🔧 Configuration Options
| Setting             | Default               | Description                         |
|--------------------|----------------------|-------------------------------------|
| `ALERT_THRESHOLD`  | `5`                   | Failed attempts before alert       |
| `TIME_WINDOW`      | `300`                 | Time window in seconds             |
| `LOG_FILE`         | `/var/log/auth.log`   | Log file path                      |
| `TELEGRAM_BOT_TOKEN` | `nil`              | Telegram bot token                 |
| `TELEGRAM_CHAT_ID` | `nil`                 | Telegram chat ID                    |

---

## ❗ Troubleshooting

### 🔹 SSH Logs Not Detected

#### Check rsyslog:
```bash
sudo systemctl status rsyslog
```

#### Verify SSH logging:
```bash
sudo grep "auth" /etc/rsyslog.conf
```

#### Test log monitoring:
```bash
echo "Feb 03 14:22:10 raspberrypi sshd[3245]: Failed password for root from 192.168.1.50 port 54567 ssh2" | sudo tee -a /var/log/auth.log
```

### 🔹 Telegram Notifications Not Working

#### Verify bot token and chat ID
#### Test bot manually:
```bash
curl -X POST "https://api.telegram.org/bot<YourBOTToken>/sendMessage" -d "chat_id=<YourChatID>&text=Test"
```

---

## 📌 Roadmap
✅ Advanced attack detection algorithms  
✅ Web dashboard with attack statistics  
✅ AbuseIPDB integration  
✅ OpenWrt compatibility  
✅ False positive reduction  
✅ Attack database  
✅ IP whitelist system  

---

## 📜 License
Released under the **Creative Commons Zero (CC0) License** – free to use and modify.

