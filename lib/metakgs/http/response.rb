require 'metakgs/http/response/cacheable'
require 'net/http'

module MetaKGS
  class HTTP
    class Response

      CACHEABLE_STATUS_CODES = [
        Net::HTTPOK,
        Net::HTTPNonAuthoritativeInformation,
        Net::HTTPNoContent,
        Net::HTTPMultipleChoice,
        Net::HTTPMovedPermanently,
        Net::HTTPNotFound,
        Net::HTTPMethodNotAllowed,
        Net::HTTPGone,
        Net::HTTPRequestURITooLong,
        Net::HTTPNotImplemented,
      ]

      def initialize( res )
        @response = res
        @cacheable_status_code = CACHEABLE_STATUS_CODES.any? { |r| r === res }
        self.extend Cacheable if cacheable_status_code?
      end

      def cacheable_status_code?
        @cacheable_status_code
      end

      def content_type
        response.content_type
      end

      def body
        response.body
      end

    private

      attr_reader :response

    end
  end
end

