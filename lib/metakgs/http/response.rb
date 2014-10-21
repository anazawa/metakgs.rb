require 'metakgs/http/response/cacheable'
require 'net/http'
require 'time'

module MetaKGS
  class HTTP
    module Response

      CACHEABLE_CLASSES = [
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

      def self.extended( response )
        response.extend Cacheable if response.cacheable_class?
      end

      def cacheable_class?
        return @cacheable_class unless @cacheable_class.nil?
        @cacheable_class = CACHEABLE_CLASSES.any? { |klass| klass === self }
      end

      def last_modified
        has_last_modified? ? Time.httpdate( self['Last-Modified'] ) : nil
      end

      def has_last_modified?
        key? 'Last-Modified'
      end

      def etag
        self['ETag']
      end

      def has_etag?
        key? 'ETag'
      end

      def date
        has_date? ? Time.httpdate( self['Date'] ) : nil
      end

      def has_date?
        key? 'Date'
      end

      def expires
        has_expires? ? Time.httpdate( self['Expires'] ) : nil
      end

      def has_expires?
        key? 'Expires'
      end

      def retry_after
        value = self['Retry-After']

        if value and value =~ /^\d+$/
          time = ( has_date? ? date : Time.now ) + value.to_i
        elsif value
          time = Time.httpdate value
        else
          time = nil
        end

        time
      end

      def has_retry_after?
        key? 'Retry-After'
      end

    end
  end
end

