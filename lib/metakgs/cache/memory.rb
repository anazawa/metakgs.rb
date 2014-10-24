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
        storage.key?(key) ? deep_clone(storage[key]) : nil
      end

      def store_object( object )
        storage[object.key] = deep_clone object
      end

      def delete_object( key )
        storage.delete key
      end

      def object_keys
        storage.keys
      end

    private

      def deep_clone( object )
        Marshal.load Marshal.dump(object)
      end

    end
  end
end

