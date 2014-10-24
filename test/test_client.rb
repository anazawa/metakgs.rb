require 'metakgs/client'
require 'metakgs/cache/memory'
require 'test/unit'
require 'timecop'
require 'webmock/test_unit'
require File.expand_path '../helper', __FILE__

class TestClient < Test::Unit::TestCase

  def test_attributes
    client = MetaKGS::Client.new
    assert client.logger.is_a? Logger
    assert client.default_header.is_a? MetaKGS::HTTP::Header
    assert client.agent =~ /^MetaKGS Ruby Gem \d+\.\d+\.\d+$/
    assert client.cache.is_a? MetaKGS::Cache
    assert client.api_endpoint == 'http://metakgs.org/api'
    assert client.read_timeout.nil?
    assert client.open_timeout.nil?
  end

  def test_uri_for
    client = MetaKGS::Client.new

    {
      'foo/bar'                => 'http://metakgs.org/api/foo/bar',
      'http://example.com/foo' => 'http://example.com/foo',
    }.each do |input, expected|
      actual = client.uri_for input
      assert_equal expected, actual, "uri_for('#{input}') should return '#{expected}'"
    end
  end

  def test_get
    client = MetaKGS::Client.new
    client.logger.level = Logger::WARN

    stub_request( :any, 'metakgs.org/api/test-timeout' ).to_timeout
    stub_request( :get, 'metakgs.org/api/test-accepted' ).to_return( :status => 202 )
    stub_request( :get, 'metakgs.org/api/test-not-found' ).to_return( :status => 404 )
    stub_request( :get, 'metakgs.org/api/test-bad-gateway' ).to_return( :status => 502 )

    assert_raise MetaKGS::Error::TimeoutError do
      client.get 'test-timeout'
    end

    assert_raise MetaKGS::Error::TimeoutError do
      client.get 'test-accepted'
    end

    assert_raise MetaKGS::Error::ResourceNotFound do
      client.get 'test-not-found'
    end

    assert_raise MetaKGS::Error::ClientError do
      client.get 'test-bad-gateway'
    end
  end

  def test_conditional_get
    now = Time.now
    later = now + 60

    client = MetaKGS::Client.new( :cache => MetaKGS::Cache::Memory.new )
    client.logger.level = Logger::WARN

    ok = stub_request(
      :get, 'metakgs.org/api/test-conditional-get'
    ).
    to_return(
      :status => 200,
      :headers => {
        'Date' => now.httpdate,
        'ETag' => '"foo"',
        'Cache-Control' => [ 'public', 'max-age=10' ],
      },
      :body => 'hello',
    )

    not_modified = stub_request(
      :get, 'metakgs.org/api/test-conditional-get'
    ).
    with(
      :headers => {
        'If-None-Match' => '"foo"',
      },
    ).
    to_return(
      :status => 304, 
      :headers => {
        'Date' => later.httpdate,
        'ETag' => '"foo"',
        'Cache-Control' => [ 'public', 'max-age=10' ],
      },
    )

    response = client.get 'test-conditional-get'
    assert_equal 'hello', response.body
    assert_equal now.to_i, response.date.to_i
    assert_requested ok

    Timecop.freeze later do
      response = client.get 'test-conditional-get'
      assert_equal 'hello', response.body
      assert_equal later.to_i, response.date.to_i
      assert_requested not_modified
    end
  end

end

