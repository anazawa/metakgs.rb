# copied and rearranged from faraday/error.rb:
# https://github.com/lostisland/faraday/blob/master/lib/faraday/error.rb

module MetaKGS
  class Error < StandardError
    class ClientError < Error

      def initialize( exception )
        @exception = nil
        if exception.respond_to? :backtrace
          super( exception.message )
          @exception = exception
        elsif Net::HTTPResponse === exception
          super( "the server responded with status #{exception.code}" )
        else
          super( exception.to_s )
        end
      end

      def backtrace
        if @exception
          @exception.backtrace
        else
          super
        end
      end

    end

    class ConnectionFailed < ClientError; end
    class TimeoutError     < ClientError; end
    class ResourceNotFound < ClientError; end
    class ParsingError     < ClientError; end

  end
end

