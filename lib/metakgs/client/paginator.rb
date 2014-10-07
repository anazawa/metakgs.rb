module MetaKGS
  class Client
    module Paginator

      def link
        raise "call to abstract method 'link'"
      end

      def get( url )
        raise "call to abstract method 'get'"
      end

      def has_next?
        !link["next"].nil?
      end

      def next
        has_next? && get(link["next"])
      end

      def has_prev?
        !link["prev"].nil?
      end

      def prev
        has_prev? && get(link["prev"])
      end

      def first
        get link["first"]
      end

      def last
        get link["last"]
      end

    end
  end
end

