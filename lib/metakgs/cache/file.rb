require 'digest'
require 'metakgs/cache'
require 'tmpdir'

module MetaKGS
  class Cache
    class File < Cache

      attr_reader :cache_root

      def initialize( args = {} )
        super

        if args.has_key?(:cache_root) then
          @cache_root = args[:cache_root]
        else
          @cache_root = Dir.mktmpdir
          ObjectSpace.define_finalizer(self, proc {
            FileUtils.remove_entry_secure cache_root
          })
        end
      end

      def build_path( url )
        ::File.join( cache_root, Digest::MD5.hexdigest(url.to_s) ) 
      end

      def get( url )
        path = build_path url

        response = begin
          ::File.open(path) do |file|
            Marshal.load( file )
          end
        rescue => evar
          warn evar
        end
          
        return unless response.is_a? Net::HTTPResponse
        return if response and expired? response

        response
      end

      def set( url, response )
        path = build_path url

        purge if auto_purge

        ::File.open(path, 'w+') do |file|
          Marshal.dump( response, file )
        end
      end

      def purge
        Dir.foreach(cache_root) do |filename|
          path = ::File.join( cache_root, filename )

          next if filename == '.' or filename == '..'

          response = begin
            ::File.open(path) do |file|
              Marshal.load( file )
            end
          rescue => evar
            warn evar
          end

          next unless response
          next unless response.is_a? Net::HTTPResponse

          ::File.unlink( path ) if expired? response
        end
      end

    end
  end
end
