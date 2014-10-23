require 'metakgs/http/header'
require 'test/unit'

class TestHTTPHeader < Test::Unit::TestCase

  def test_initialize_copy
    header = MetaKGS::HTTP::Header.new( 'Foo' => 'bar' )
    copy = header.dup
    assert_equal header.to_hash, copy.to_hash

    copy['Bar'] = 'baz'
    diff = copy.to_hash.to_a - header.to_hash.to_a
    assert_equal [[ 'bar', ['baz'] ]], diff
  end

end

