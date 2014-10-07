module MetaKGS
  class Cache
    class Object

      attr_reader :key, :value, :created_at, :expires_at

      def initialize( args = {} )
        @key = args[:key]
        @value = args[:value]
        @created_at = Time.now
        @expires_at = args[:expires_at] || Time.now
      end

      def expired?
        Time.now >= expires_at
      end

    end
  end
end

