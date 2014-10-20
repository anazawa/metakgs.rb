module MetaKGS
  class Cache
    class Null < Cache

      def fetch_object( key )
      end

      def store_object( object )
      end

      def delete_object( key )
      end

      def object_keys
        []
      end

    end
  end
end
