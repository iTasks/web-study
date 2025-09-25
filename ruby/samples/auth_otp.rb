require 'sinatra'
require 'redis'
require 'jwt'
require 'twilio-ruby'
require 'dotenv/load'

##
# Constants using environment variables to configure the Twilio client and Redis.
##
ACC_SID = ENV['TWILIO_ACCOUNT_SID']
AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']
FROM_PHONE = ENV['TWILIO_PHONE_NUMBER']

##
# Redis Configuration
# Establishes connection to Redis server for caching OTPs.
##
redis = Redis.new(host: "localhost", port: 6379, db: 0)

##
# Twilio client configuration
# Initializes the Twilio client with account SID and authentication token.
##
twilio_client = Twilio::REST::Client.new(ACC_SID, AUTH_TOKEN)

##
# Sinatra Server Port Configuration
# Specifies the port on which Sinatra will run.
##
set :port, 4567

##
# Route to generate OTP and send via SMS using Twilio
# Calls the Twilio API to send a generated OTP to the provided phone number.
#
# @return [String] confirmation that the OTP has been sent.
##
get '/otp/generate' do
  username = params['username']
  phone = params['phone']
  otp = rand.to_s[2..7]  # Generate a random 6-digit OTP
  redis.setex("otp:#{username}", 300, otp) # Store OTP with expiry of 5 minutes
  
  message = twilio_client.messages.create(
    from: FROM_PHONE,
    to: phone,
    body: "Your OTP is #{otp}"
  )

  "OTP sent to #{phone}"
end

##
# Route for validating the provided OTP and generating a JWT
# Validates the OTP provided by the user against the one stored in Redis and generates a JWT on success.
#
# @return [JSON] either an access token or an error message.
##
post '/otp/validate' do
  payload = JSON.parse(request.body.read)
  username = payload['username']
  otp_user = payload['otp']
  otp_stored = redis.get("otp:#{username}")
  
  if otp_stored && otp_stored == otp_user
    token = JWT.encode({user_id: username, exp: Time.now.to_i + 3600}, 'my$ecretK3y', 'HS256')
    {access_token: token}.to_json
  else
    {message: 'Invalid or expired OTP'}.to_json
  end
end

##
# Main execution block
# Runs the Sinatra app if this file is the main program file.
##
run! if app_file == $0
