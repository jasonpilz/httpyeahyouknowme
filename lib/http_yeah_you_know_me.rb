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

      first_line = client.gets.split(' ')
      env_hash['REQUEST_METHOD'] = first_line[0]
      env_hash['PATH_INFO'] = first_line[1]
      protocol = first_line[2]

      loop do
        next_line = client.gets
        break if next_line == "\r\n"
        env_hash[next_line.split(': ')[0]] = next_line.split(': ')[1].chomp
      end

      # binding.pry
      # client.eof?
      env_hash['rack.input'] = StringIO.new # (body? params?)

      # call app
      response = @app.call(env_hash)

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
