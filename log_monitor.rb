LOG_FILE = "/var/log/auth.log"
ALERT_THRESHOLD = 5
TIME_WINDOW = 300  # 5 minutes in seconds

def watch_logs
  failed_attempts = Hash.new { |h, k| h[k] = [] }
  
  File.open(LOG_FILE, "r") do |file|
    file.seek(0, IO::SEEK_END)
    
    loop do
      line = file.gets
      next unless line
      
      if line.include?("Failed password for")
        timestamp = Time.now
        ip = line.split("from")[1].split[0]
        
        # Add new attempt with timestamp
        failed_attempts[ip] << timestamp
        
        # Remove attempts older than TIME_WINDOW
        failed_attempts[ip].reject! { |t| timestamp - t > TIME_WINDOW }
        
        # Alert if threshold reached within time window
        if failed_attempts[ip].length >= ALERT_THRESHOLD
          alert("Brute-force attack detected!\nIP: #{ip}\nAttempts: #{failed_attempts[ip].length} in last #{TIME_WINDOW/60} minutes")
          failed_attempts[ip].clear
        end
      end
      
      sleep 1
    end
  end
end

def alert(message)
  system("curl -X POST -H 'Content-Type: application/json' -d '{\"event\":\"ALERT\", \"details\":\"#{message}\"}' http://localhost:4567/log")
end

watch_logs
