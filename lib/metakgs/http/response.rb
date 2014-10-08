require 'json'
require 'time'

module MetaKGS
  class HTTP
    class Response

    private

      attr_accessor :response
      attr_accessor :old_response

    public

      def initialize( response )
        self.response = response
      end

      def merge( response )
        dup.merge! response
      end

      def merge!( response )
        self.old_response = self.response unless old_response
        self.response = response
        self
      end

      def date
        Time.parse response['Date']
      end

      def last_modified
        Time.parse response['Last-Modified']
      end

      def etag
        response['ETag']
      end

      def cache_control
        response.get_fields('Cache-Control') || []
      end

      def body
        JSON.parse response.body || old_response.body
      end

      def expired?
        max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
        !max_age || Time.now >= date + max_age.to_i
      end

    end
  end
end

