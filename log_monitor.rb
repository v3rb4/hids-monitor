LOG_FILE = "/var/log/auth.log"
ALERT_THRESHOLD = 5  

def watch_logs
  failed_attempts = Hash.new(0)

  File.open(LOG_FILE, "r") do |file|
    file.seek(0, IO::SEEK_END)  
    loop do
      line = file.gets
      next unless line

      if line.include?("Failed password for")
        ip = line.split("from")[1].split[0]
        failed_attempts[ip] += 1

        if failed_attempts[ip] >= ALERT_THRESHOLD
          alert("Brute-force detected from #{ip}")
          failed_attempts[ip] = 0
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
