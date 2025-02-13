#!/usr/bin/env ruby

require 'json'
require 'time'
require 'logger'

class LogMonitor
  # Configuration constants
  LOG_FILE = '/var/log/auth.log'
  ALERT_THRESHOLD = 5
  TIME_WINDOW = 300  # 5 minutes in seconds
  SLEEP_INTERVAL = 0.1  # Reduced sleep time for more responsive monitoring
  ALERT_ENDPOINT = 'http://localhost:4567/log'

  def initialize
    @failed_attempts = Hash.new { |h, k| h[k] = [] }
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def watch_logs
    @logger.info("Starting log monitoring of #{LOG_FILE}")
    
    begin
      File.open(LOG_FILE, 'r') do |file|
        file.seek(0, IO::SEEK_END)
        
        loop do
          process_new_lines(file)
          sleep SLEEP_INTERVAL
        end
      end
    rescue Errno::ENOENT
      @logger.error("Log file not found: #{LOG_FILE}")
      exit 1
    rescue Interrupt
      @logger.info("Monitoring stopped by user")
      exit 0
    rescue StandardError => e
      @logger.error("Unexpected error: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
      exit 1
    end
  end

  private

  def process_new_lines(file)
    while line = file.gets
      process_line(line.chomp) if line.include?('Failed password for')
    end
  end

  def process_line(line)
    timestamp = Time.now
    ip = extract_ip(line)
    return unless ip

    update_attempts(ip, timestamp)
    check_threshold(ip)
  end

  def extract_ip(line)
    if match = line.match(/Failed password for .* from (\S+)/)
      match[1]
    end
  end

  def update_attempts(ip, timestamp)
    @failed_attempts[ip] << timestamp
    cleanup_old_attempts(ip, timestamp)
  end

  def cleanup_old_attempts(ip, current_time)
    @failed_attempts[ip].reject! { |t| current_time - t > TIME_WINDOW }
  end

  def check_threshold(ip)
    attempts = @failed_attempts[ip].length
    if attempts >= ALERT_THRESHOLD
      send_alert(ip, attempts)
      @failed_attempts[ip].clear
    end
  end

  def send_alert(ip, attempts)
    message = {
      event: 'ALERT',
      details: "Brute-force attack detected!\nIP: #{ip}\nAttempts: #{attempts} in last #{TIME_WINDOW/60} minutes",
      timestamp: Time.now.iso8601,
      ip: ip,
      attempts: attempts
    }

    begin
      cmd = [
        'curl', '-X', 'POST',
        '-H', 'Content-Type: application/json',
        '-d', message.to_json,
        ALERT_ENDPOINT
      ]
      
      success = system(*cmd)
      unless success
        @logger.error("Failed to send alert for IP: #{ip}")
      end
    rescue StandardError => e
      @logger.error("Error sending alert: #{e.message}")
    end
  end
end

# Start monitoring if this file is run directly
if __FILE__ == $PROGRAM_NAME
  LogMonitor.new.watch_logs
end
