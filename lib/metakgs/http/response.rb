require 'net/http'
require 'time'

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

    private

      attr_accessor :response
      attr_accessor :response_304

    public

      def initialize( res )
        @response = res
      end

      def merge_304( res )
        dup.merge_304! res
      end

      def merge_304!( res )
        raise "Not a 304 response: #{res}" unless Net::HTTPNotModified === res
        raise "Not a cacheable response" unless cacheable_status_code?
        @response_304 = res
        self
      end

      def cacheable_status_code?
        CACHEABLE_STATUS_CODES.any? { |res| res === response }
      end

      def code_type
        response.class
      end

      def date
        res = response_304 || response
        res.key?('Date') ? Time.httpdate( res['Date'] ) : nil
      end

      def has_date?
        res = response_304 || response
        res.key? 'Date'
      end

      def last_modified
        res = response_304 || response
        res.key?('Last-Modified') ? Time.httpdate( res['Last-Modified'] ) : nil
      end

      def has_last_modified?
        res = response_304 || response
        res.key? 'Last-Modified'
      end

      def expires
        res = response_304 || response
        res.key?('Expires') ? Time.httpdate( res['Expires'] ) : nil
      end

      def has_expires?
        res = response_304 || response
        res.key? 'Expires'
      end

      def etag
        response['ETag']
      end

      def has_etag?
        res = response_304 || response
        res.key? 'ETag'
      end

      def cache_control
        res = response_304 || response
        directives = res.get_fields 'Cache-Control'

        return unless directives

        value = {}
        directives.each do |directive|
          ( token, argument ) = directive.split '=', 2
          value[token] = argument || true unless token.empty?
        end

        [ 'max-age', 's-maxage' ].each do |token|
          next unless value.key? token
          value[token] = value[token].to_i
          value[token] -= res['Age'].to_i if res.key? 'Age'
        end

        value
      end

      def content_type
        response.content_type
      end

      def body
        response.body
      end

      def age
        has_date? ? ( Time.now - date ).to_i : nil
      end

      alias :has_age? :has_date?

      def freshness_lifetime
        cache = cache_control || {}
        lifetime = cache['s-maxage'] || cache['max-age']
        lifetime = ( Time.now - expires ).to_i if !lifetime and has_expires?
        lifetime
      end

      def cacheable?( shared_cache = false )
        res = response_304 || response
        cache = cache_control || {}

        return false if cache['no-store']
        return false if shared_cache and cache['private']
        return false if !cacheable_status_code?
        return false if !has_last_modified? and !has_etag?

        fresh?
      end

      def fresh?
        lifetime = freshness_lifetime
        has_age? && lifetime ? lifetime > age : false
      end

    end
  end
end

