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

      def if_modified_since=( value )
        self['If-Modified-Since'] = value.httpdate
      end

      def to_hash
        hash = {}
        each do |key, value|
          hash[key] = value
        end

        hash
      end

    end
  end
end

