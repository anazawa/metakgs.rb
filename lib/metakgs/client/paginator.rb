module MetaKGS
  class Client
    module Paginator

      attr_accessor :link
      attr_accessor :client

      def get( path )
        client.get_content path
      end

      def has_next?
        !link['next'].nil?
      end

      def next
        has_next? ? get(link['next']) : nil
      end

      def has_prev?
        !link['prev'].nil?
      end

      def prev
        has_prev? ? get(link['prev']) : nil
      end

      def first
        get link['first']
      end

      def last
        get link['last']
      end

    end
  end
end

