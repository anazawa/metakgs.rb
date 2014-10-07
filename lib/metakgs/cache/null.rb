module MetaKGS
  class Cache
    class Null

      def do_fetch( key )
      end

      def do_store( object )
        object
      end

      def do_delete( key )
      end

      def do_keys
        []
      end

    end
  end
end
