require 'digest'
require 'metakgs/cache'
require 'tmpdir'

module MetaKGS
  class Cache
    class File < Cache

      attr_reader :cache_root

      def initialize( args = {} )
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

        return unless ::File.exists?( path )

        response = ::File.open(path) do |file|
          Marshal.load( file )
        end

        return if expired? response

        response
      end

      def set( url, response )
        ::File.open(build_path(url), 'w+') do |file|
          Marshal.dump( response, file )
        end
      end

    end
  end
end
