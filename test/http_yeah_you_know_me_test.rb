require 'stringio'
require_relative '../lib/http_yeah_you_know_me'

class HttpYeahYouKnowMeTest < Minitest::Test
  def test_parse_reads_the_first_line
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "\r\n")
    env_hash = HttpYeahYouKnowMe.parse(client)

    assert_equal 'POST', env_hash['REQUEST_METHOD']
    assert_equal '/to_braille', env_hash['PATH_INFO']
    assert_equal 'HTTP/1.1', env_hash['HTTP_VERSION']
  end

  def test_parse_reads_the_headers
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "Jason: 10\r\n" +
                          "Content-Type: html\r\n" +
                          "\r\n")
    env_hash = HttpYeahYouKnowMe.parse(client)

    assert_equal '10', env_hash['Jason']
    assert_equal 'html', env_hash['Content-Type']
  end

  def test_parse_reads_body_up_to_content_length
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "Content-Length: 10\r\n" +
                          "\r\n" +
                          "0123456789This should not show")
    env_hash = HttpYeahYouKnowMe.parse(client)
    assert_equal "0123456789", env_hash['rack.input'].gets
  end

  def test_response_writes_the_first_line
    skip
  end
end
