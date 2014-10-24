require 'metakgs/cache'

module MetaKGS
  class Cache
    class Memory < Cache

      attr_reader :storage

      def initialize( args = {} )
        super
        @storage = {}
      end

      def fetch_object( key )
        storage[key]
      end

      def store_object( object )
        storage[object.key] = object
      end

      def delete_object( key )
        storage.delete key
      end

      def object_keys
        storage.keys
      end

    end
  end
end

