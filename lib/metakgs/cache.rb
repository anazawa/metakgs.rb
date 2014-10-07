require 'metakgs/cache/object'

module MetaKGS
  class Cache

    attr_accessor :auto_purge

    def initialize( args = {} )
      @auto_purge = args.has_key?(:auto_purge) ? args[:auto_purge] : false
    end

    def get( key )
      object = fetch key

      return unless object

      if object.expired?
        delete key
        return
      end

      object.value
    end

    def set( key, value, expires_at )
      purge if auto_purge
      store build_object( key, value, expires_at )
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

    def fetch( key )
      raise "call to abstract method 'fetch'"
    end

    def store( object )
      raise "call to abstract method 'store'"
    end

    def delete( key )
      raise "call to abstract method 'delete'"
    end

    def keys
      raise "call to abstract method 'keys'"
    end

  end
end
