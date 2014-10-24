require 'test/unit'
require 'metakgs/client'
require File.expand_path '../helper', __FILE__

class TestClient < Test::Unit::TestCase

  def setup
    @client = MetaKGS::Client.new
  end

  def test_attributes
    assert @client.logger.is_a? Logger
    assert @client.default_header.is_a? MetaKGS::HTTP::Header
    assert @client.agent =~ /^MetaKGS Ruby Gem \d+\.\d+\.\d+$/
    assert @client.cache.is_a? MetaKGS::Cache
    assert @client.api_endpoint == 'http://metakgs.org/api'
    assert @client.read_timeout.nil?
    assert @client.open_timeout.nil?
  end

  def test_uri_for
    {
      'foo/bar'                => 'http://metakgs.org/api/foo/bar',
      'http://example.com/foo' => 'http://example.com/foo',
    }.each do |input, expected|
      actual = @client.uri_for input
      assert_equal expected, actual, "uri_for('#{input}') should return '#{expected}'"
    end
  end

end

