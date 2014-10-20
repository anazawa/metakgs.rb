require 'net/http'

module MetaKGS
  class HTTP
    class Header

      include Net::HTTPHeader

      def initialize( args = {} )
        initialize_http_header args
      end

      def dclone
        Marshal.load( Marshal.dump(self) )
      end

      def if_none_match=( value )
        self['If-None-Match'] = value
      end

      def if_modified_since=( value )
        self['If-Modified-Since'] = value.httpdate
      end

    end
  end
end

