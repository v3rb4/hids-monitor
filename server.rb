require 'sinatra'
require 'json'
require 'telegram/bot'

# Configure your Telegram bot token and chat ID
TELEGRAM_BOT_TOKEN = 'YOUR_BOT_TOKEN'
TELEGRAM_CHAT_ID = 'YOUR_CHAT_ID'

set :bind, '0.0.0.0'

def send_telegram_alert(message)
  begin
    Telegram::Bot::Client.new(TELEGRAM_BOT_TOKEN).api.send_message(
      chat_id: TELEGRAM_CHAT_ID,
      text: "🚨 HIDS Alert!\n#{message}",
      parse_mode: 'HTML'
    )
  rescue => e
    puts "Failed to send Telegram alert: #{e.message}"
  end
end

# Status page
get '/' do
  "🚀 HIDS is running on Raspberry Pi 5!"
end

# API for logs
post '/log' do
  request.body.rewind
  log_entry = JSON.parse(request.body.read)
  
  # Log to file
  File.open("hids.log", "a") do |file|
    file.puts("#{Time.now} - #{log_entry['event']} - #{log_entry['details']}")
  end
  
  # Send Telegram alert if it's an ALERT event
  if log_entry['event'] == 'ALERT'
    send_telegram_alert(log_entry['details'])
  end
  
  status 200
  { message: "Logged successfully!" }.to_json
end
