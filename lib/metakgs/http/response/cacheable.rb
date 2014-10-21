require 'metakgs/error'
require 'net/http'
require 'time'

module MetaKGS
  class HTTP
    module Response
      module Cacheable

        def merge_304( res )
          dclone.merge_304! res
        end

        def merge_304!( res )
          raise "Not a 304 response: #{res}" unless Net::HTTPNotModified === res

          self['Date']          = res['Date']
          self['Age']           = res['Age']
          self['Expires']       = res['Expires']
          self['Last-Modified'] = res['Last-Modified']
          self['ETag']          = res['ETag']

          if res.key? 'Cache-Control'
            self.delete 'Cache-Control'
            res.get_fields('Cache-Control').each do |value|
              self.add_field 'Cache-Control', value
            end
          end

          self
        end

        def cacheable?( shared_cache = false )
          cache = cache_control || {}

          return false if cache['no-store']
          return false if shared_cache and cache['private']
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

        def cache_control
          directives = get_fields 'Cache-Control'

          return unless directives

          value = {}
          directives.each do |directive|
            ( token, argument ) = directive.split '=', 2
            value[token.downcase] = argument || true unless token.empty?
          end

          [ 'max-age', 's-maxage' ].each do |token|
            next unless value.key? token
            value[token] = value[token].to_i
            value[token] -= self['Age'].to_i if key? 'Age'
          end

          value
        end

        def age
          has_date? ? ( Time.now - date ).to_i : nil
        end

        alias :has_age? :has_date?

        def freshness_lifetime
          cache = cache_control || {}
          lifetime = cache['s-maxage'] || cache['max-age']
          lifetime = ( Time.now - expires ).to_i if !lifetime and has_expires?
          lifetime
        end

      end
    end
  end
end

