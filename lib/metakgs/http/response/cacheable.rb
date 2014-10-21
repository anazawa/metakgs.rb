require 'net/http'

module MetaKGS
  class HTTP
    module Response
      module Cacheable

        def merge_304( response )
          res = Marshal.load Marshal.dump(self)
          res.merge_304! response
        end

        def merge_304!( response )
          unless Net::HTTPNotModified === response
            raise "Not a 304 response: #{response}"
          end

          %w( Date Age Expires Last-Modified ETag ).each do |key|
            self[key] = response[key]
          end

          %w( Cache-Control ).each do |key|
            delete key
            next unless response.key? key
            response.get_fields(key).each do |value|
              add_field key, value
            end
          end

          self
        end

        def cache_control
          value = {}

          return unless has_cache_control?

          get_fields('Cache-Control').each do |directive|
            ( token, argument ) = directive.split '=', 2
            value[token.downcase] = argument || true unless token.empty?
          end

          %w( max-age s-maxage ).each do |token|
            next unless value.key? token
            value[token] = value[token].to_i
            value[token] -= self['Age'].to_i if key? 'Age'
          end

          value
        end

        def has_cache_control?
          key? 'Cache-Control'
        end

        def age
          has_date? ? ( Time.now - date ).to_i : nil
        end

        def has_age?
          has_date?
        end

        def cacheable?( shared_cache=false )
          control = cache_control || {}

          return false if control['no-store']
          return false if control['private'] and shared_cache
          return false if !has_last_modified? and !has_etag?

          fresh?
        end

        def cacheable_in_shared_cache?
          cacheable? true
        end

        def fresh?
          lifetime = freshness_lifetime
          has_age? && lifetime ? lifetime > age : false
        end

        def freshness_lifetime
          control = cache_control || {}
          lifetime = control['s-maxage'] || control['max-age']
          lifetime = ( Time.now - expires ).to_i if !lifetime and has_expires?
          lifetime
        end

      end
    end
  end
end

