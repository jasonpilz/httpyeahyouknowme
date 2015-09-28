require_relative '../lib/http_yeah_you_know_me'
require 'rest-client' # you may need to `gem install rest-client`
require 'pry'

RSpec.describe 'Acceptance test' do
  def run_server(port, app, &block)
    server = HttpYeahYouKnowMe.new(port, app)
    thread = Thread.new { server.start }
    thread.abort_on_exception = true
    block.call
  ensure
    thread.kill
    server.stop
  end


  it 'accepts and responds to a web request' do
    path_info = "this value should be overridden by the app!"

    app = lambda do |env_hash|
      path_info = env_hash['PATH_INFO']
      body      = "hello, class ^_^"
      [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
    end

    run_server 9292, app do
      response = RestClient.get 'localhost:9292/users'
      expect(response.code).to eq 200
      expect(response.headers[:omg]).to eq 'bbq'
      expect(response.body).to eq "hello, class ^_^"
      expect(path_info).to eq '/users'
    end
  end


  it 'handles multiple requests' do
    app = lambda { |env_hash| [200, {'Content-Type' => 'text/plain'}, []] }

    run_server 9292, app do
      expect(RestClient.get('localhost:9292/').code).to eq 200
      expect(RestClient.get('localhost:9292/').code).to eq 200
    end
  end


  it 'starts on the specified port' do
    app = lambda { |env_hash| [200, {'Content-Type' => 'text/plain', 'Content-Length' => 5}, ['hello']] }

    run_server 9292, app do
      expect(RestClient.get('localhost:9292/').body).to eq 'hello'
    end
  end
end
