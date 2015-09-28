require 'stringio'
require_relative '../lib/http_yeah_you_know_me'

class HttpYeahYouKnowMeTest < Minitest::Test
  def test_parse_reads_body_up_to_content_length
    client = StringIO.new("POST /to_braille HTTP/1.1\r\n" +
                          "Content-Length: 10\r\n" +
                          "\r\n" +
                          "0123456789This should not show")
    env_hash = HttpYeahYouKnowMe.parse(client)
    assert_equal "0123456789", env_hash['rack.input'].gets
  end
end
