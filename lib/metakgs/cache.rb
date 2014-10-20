require 'metakgs/cache/object'

module MetaKGS
  class Cache

    attr_accessor :auto_purge

    def initialize( args={} )
      @auto_purge = args.has_key?(:auto_purge) ? args[:auto_purge] : false
    end

    def build_object( key, value, expires_at=nil )
      MetaKGS::Cache::Object.new(
        :key   => key,
        :value => value,
        :expires_at => expires_at,
      )
    end

    def fetch( key )
      object = fetch_object key

      return unless object

      if object.expired?
        delete key
        return
      end

      object.value
    end

    def fetch_object( key )
      raise NotImplementedError, "call to abstract method 'fetch_object'"
    end

    def store( key, value, expires_at=nil )
      object = build_object key, value, expires_at
      purge if auto_purge
      store_object object
      value
    end

    def store_object( object )
      raise NotImplementedError, "call to abstract method 'store_object'"
    end

    def delete( key )
      delete_object key
    end

    def delete_object( key )
      raise NotImplementedError, "call to abstract method 'delete_object'"
    end

    def keys
      object_keys
    end

    def object_keys
      raise NotImplementedError, "call to abstract method 'object_keys'"
    end

    def purge
      keys.each do |key|
        fetch key
      end
    end

  end
end

