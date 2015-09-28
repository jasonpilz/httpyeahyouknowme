require 'sinatra/base'
require_relative 'night_write.rb'

class NightWriterServer < Sinatra::Base
  get '/to_braille' do
    "<form action='/to_braille' method='post'>
      <input type='textarea' name='english-message'></input>
      <input type='Submit'></input>
    </form>"
  end

  post '/to_braille' do
    message = params['english-message']
    braille = NightWrite.to_braille(message)
    "<pre>#{braille}</pre>"
  end
end


# switch this to use your server
use_my_server = true

if use_my_server
  require_relative 'http_yeah_you_know_me'
  server = HttpYeahYouKnowMe.new(9292, NightWriterServer)
  at_exit { server.stop }
  server.start
else
  NightWriterServer.set :port, 9292
  NightWriterServer.run!
end
