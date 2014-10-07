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
            FileUtils.remove_entry_secure( cache_root )
          })
        end
      end

    private

      def build_path( key )
        ::File.join( cache_root, Digest::MD5.hexdigest(key) ) 
      end

      def fetch( key )
        path = build_path key
        read_file path
      end

      def store( object )
        path = build_path object.key
        write_file path, object
      end

      def keys
        keys = []
        Dir.foreach(cache_root) do |filename|
          next if filename == '.' or filename == '..'
          path = ::File.join( cache_root, filename )
          object = ::File.file?( path ) && read_file( path )
          keys.push( object.key ) if object
        end

        keys
      end

      def delete( key )
        path = build_path key
        unlink_file path
      end

      def read_file( path )
        return unless ::File.exists?( path )

        begin
          ::File.open(path) do |file|
            Marshal.load( file )
          end
        rescue => evar
          warn evar
        end
      end

      def write_file( path, object )
        ::File.open(path, 'w+') do |file|
          Marshal.dump( object, file )
        end
      end
         
      def unlink_file( path )
        ::File.unlink( path ) if ::File.file?( path )
      end

    end
  end
end
