module MetaKGS
  class Client
    module Paginator

      def has_next?
        body && !body["link"]["next"].nil?
      end

      def next
        has_next? && get(body["link"]["next"])
      end

      def has_prev?
        body && !body["link"]["prev"].nil?
      end

      def prev
        has_prev? && get(body["link"]["prev"])
      end

      def first
        body && get(body["link"]["first"])
      end

      def last
        body && get(body["link"]["last"])
      end

    end
  end
end

