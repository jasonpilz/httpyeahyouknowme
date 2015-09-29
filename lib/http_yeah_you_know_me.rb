require 'socket'
require 'stringio'
require 'pry'

class HttpYeahYouKnowMe
  def initialize(port, app)
    @port = port
    @app = app
    @tcp_server = TCPServer.new(@port)
  end

  def self.parse(client)
    env_hash = {}

    # parse first line
    first_line = client.gets.split(' ')
    env_hash['REQUEST_METHOD'] = first_line[0]
    env_hash['PATH_INFO'] = first_line[1]
    env_hash['HTTP_VERSION'] = first_line[2]

    # parses headers
    loop do
      next_line = client.gets
      break if next_line == "\r\n"
      env_hash[next_line.split(': ')[0]] = next_line.split(': ')[1].chomp
    end

    # reads body up to content length
    content_length = env_hash['Content-Length'].to_i
    body = client.read(content_length)
    env_hash['rack.input'] = StringIO.new(body)
    env_hash
  end

  def response(env_hash, client)
    response = @app.call(env_hash)

    code = response[0]
    headers = response[1]
    body = response[2][0]

    # write response
    headers['CONTENT_LENGTH'] = body.length unless body.nil?
    client.print("#{env_hash['HTTP_VERSION']} #{code}\r\n")
    headers.each_pair { |k, v| client.print("#{k}: #{v}\r\n") }
    client.print("\r\n")
    client.print("#{body}\r\n")
    client.close
  end

  def start
    loop do
      # read request
      client = @tcp_server.accept
      env_hash = self.class.parse(client)
      # call app
      response(env_hash, client)
    end
  end

  def stop
    @tcp_server.close_read
    @tcp_server.close_write
  end
end
