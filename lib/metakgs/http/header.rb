require 'net/http'

module MetaKGS
  class HTTP
    class Header

      include Net::HTTPHeader

      def initialize( args={} )
        initialize_http_header args
      end

      def initialize_copy( header )
        hash = header.to_hash
        header.initialize_http_header nil
        hash.each do |key, values|
          values.each do |value|
            header.add_field key, value
          end
        end
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

