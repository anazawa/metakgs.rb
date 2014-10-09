require 'time'

module MetaKGS
  class HTTP
    class Response

    private

      attr_accessor :response
      attr_accessor :old_response

    public

      def initialize( res )
        @response = res
      end

      def merge( res )
        dup.merge! res
      end

      def merge!( res )
        @old_response = response unless old_response
        @response = res
        self
      end

      def code_type
        old_response ? old_response.class : response.class
      end

      def date
        has_date? ? Time.parse( response['Date'] ) : nil
      end

      def has_date?
        response.key? 'Date'
      end

      def last_modified
        has_last_modified? ? Time.parse( response['Last-Modified'] ) : nil
      end

      def has_last_modified?
        response.key? 'Last-Modified'
      end

      def etag
        response['ETag']
      end

      def has_etag?
        response.key? 'ETag'
      end

      def cache_control
        response.get_fields('Cache-Control') || []
      end

      def content_type
        res = response.body ? response : old_response
        res && res.content_type
      end

      def body
        response.body || old_response.body
      end

      def expired?
        max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
        !max_age || !has_date? || Time.now >= date + max_age.to_i
      end

    end
  end
end

