require 'test/unit'
require 'metakgs/cache/file'
require 'metakgs/cache/null'
require 'metakgs/cache/memory'

class TestCache < Test::Unit::TestCase

  def test_null
    cache = MetaKGS::Cache::Null.new
    assert cache.is_a? MetaKGS::Cache
  end

  def test_memory
    cache = MetaKGS::Cache::Memory.new
    assert cache.is_a? MetaKGS::Cache
  end

  def test_file
    cache = MetaKGS::Cache::File.new
    assert cache.is_a? MetaKGS::Cache
    assert cache.fetch('foo').nil?
    assert_equal cache.keys, []

    cache.store 'foo', 'bar'
    assert_equal 'bar', cache.fetch('foo')
    assert_equal cache.keys, [ 'foo' ]

    cache.delete 'foo'
    assert cache.fetch('foo').nil?
    assert_equal cache.keys, []
  end

end

