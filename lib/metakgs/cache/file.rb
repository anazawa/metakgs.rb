require 'digest'
require 'fileutils'
require 'metakgs/cache'
require 'tempfile'
require 'tmpdir'

module MetaKGS
  class Cache
    class File < Cache

      attr_reader :cache_root

      def initialize( args = {} )
        super

        if args.has_key? :cache_root
          @cache_root = args[:cache_root]
        else
          @cache_root = Dir.mktmpdir
          ObjectSpace.define_finalizer self, proc {
            FileUtils.remove_entry_secure cache_root
          }
        end
      end

      def fetch_object( key )
        marshal_load filename_for(key)
      end

      def store_object( object )
        filename = filename_for object.key
        marshal_dump filename, object
      end

      def object_keys
        keys = []

        Dir.foreach(cache_root) do |filename|
          next if filename == '.' or filename == '..'
          next unless ::File.file? path_to(filename)
          object = marshal_load filename
          keys.push object.key if object
        end

        keys
      end

      def delete_object( key )
        path = path_to filename_for(key)
        ::File.unlink path if ::File.file? path
      end

    private

      def filename_for( key )
        Digest::MD5.hexdigest key
      end

      def path_to( filename )
        ::File.join cache_root, filename
      end

      def marshal_load( filename )
        path = path_to filename
        object = nil

        return unless ::File.exists? path

        begin
          ::File.open(path) do |file|
            object = Marshal.load file
          end
        rescue => evar
          warn evar
        end

        object
      end

      def marshal_dump( filename, object )
        path = path_to filename

        tempfile = Tempfile.new '', cache_root
        Marshal.dump object, tempfile
        tempfile.close

        ::File.rename tempfile.path, path
      end

    end
  end
end
