require 'socket'
require 'stringio'
require 'pry'

class HttpYeahYouKnowMe
  def initialize(port, app)
    @port = port
    @app = app
    @tcp_server = TCPServer.new(@port)
  end

  def start
    loop do
      # read request
      client = @tcp_server.accept
      env_hash = {}

      request = client.gets.split(' ')
      env_hash['REQUEST_METHOD'] = request[0]
      env_hash['PATH_INFO'] = request[1]
      env_hash['rack.input'] = StringIO.new
      env_hash['Content-Type'] = 'text/html'
      protocol = request[2]

      # call app
      response = @app.call(env_hash)
      # binding.pry
      code = response[0]
      headers = response[1]
      body = response[2][0]
      # write response
      headers['Content-Length'] = body.length unless body.nil?
      client.print("#{protocol} #{code}\r\n")
      headers.each_pair { |k, v| client.print("#{k}: #{v}\r\n") }
      client.print("\r\n")
      client.print("#{body}\r\n")
      client.close
    end
  end

  def stop
    @tcp_server.close_read
    @tcp_server.close_write
  end
end
