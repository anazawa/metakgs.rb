require 'metakgs/cache/object'

module MetaKGS
  class Cache

    attr_accessor :auto_purge

    def initialize( args = {} )
      @auto_purge = args.has_key?(:auto_purge) ? args[:auto_purge] : false
    end

    def fetch( key )
      object = do_fetch key

      return unless object

      if object.expired?
        delete key
        return
      end

      object.value
    end

    def store( key, value, expires_at )
      purge if auto_purge
      do_store build_object( key, value, expires_at )
    end

    def delete( key )
      do_delete key
    end

    def keys
      do_keys
    end

    def purge
      keys.each do |key|
        get key
      end
    end

  private

    def build_object( key, value, expires_at )
      MetaKGS::Cache::Object.new(
        :key   => key,
        :value => value,
        :expires_at => expires_at,
      )
    end

    def do_fetch( key )
      raise "call to abstract method 'do_fetch'"
    end

    def do_store( object )
      raise "call to abstract method 'do_store'"
    end

    def do_delete( key )
      raise "call to abstract method 'do_delete'"
    end

    def do_keys
      raise "call to abstract method 'do_keys'"
    end

  end
end
