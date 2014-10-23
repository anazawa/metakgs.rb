require 'metakgs/http/response'
require 'net/http'
require 'test/unit'

class TestHTTPResponse < Test::Unit::TestCase

  def test_cacheable_class
    assert build_200.cacheable_class?
    assert !build_202.cacheable_class?
  end

  def test_body
    response = build_200({ 'Content-Type' => 'application/json' }, '{"foo":"bar"}')
    assert_equal({ 'foo' => 'bar' }, response.body)

    assert_raise MetaKGS::Error::ParsingError do
      build_200({ 'Content-Type' => 'application/json' }, '{"foo":"bar"')
    end
  end

  def test_merge_304
    ok = build_200({ 'Date' => 'Thu, 23 Oct 2014 17:47:03 GMT' })
    not_modified = build_304({ 'Date' => 'Fri, 24 Oct 2014 17:47:03 GMT' })
    assert_equal 'Fri, 24 Oct 2014 17:47:03 GMT', ok.merge_304(not_modified)['Date']

    assert_raise ArgumentError do
      build_200.merge_304 build_202
    end
  end

  def test_cache_control
    response = build_200
    response.add_fields 'Cache-Control', 'public', 'max-age=60'
    assert_equal({ 'public' => true, 'max-age' => 60 }, response.cache_control)
  end

  def build_200( *args )
    build_response Net::HTTPOK, '200', 'OK', *args
  end

  def build_202( *args )
    build_response Net::HTTPAccepted, '202', 'Accepted', *args
  end

  def build_304( *args )
    build_response Net::HTTPNotModified, '304', 'Not Modified', *args
  end

  def build_response( response_class, code, message, header = nil, body = nil )
    response = response_class.new( '1.1', code, message )
    response.define_singleton_method(:body) { body }
    response.define_singleton_method(:body=) { |value| body = value }
    response.initialize_http_header header
    response.extend MetaKGS::HTTP::Response
  end

end

