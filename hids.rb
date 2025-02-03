require 'sinatra'
require 'json'

set :bind, '0.0.0.0' 

# Status page
get '/' do
  "🚀 HIDS is running on Raspberry Pi 5!"
end

# API for logs
post '/log' do
  request.body.rewind
  log_entry = JSON.parse(request.body.read)
  
  File.open("hids.log", "a") do |file|
    file.puts("#{Time.now} - #{log_entry['event']} - #{log_entry['details']}")
  end

  status 200
  { message: "Logged successfully!" }.to_json
end
