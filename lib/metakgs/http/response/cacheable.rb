require 'metakgs/error'
require 'net/http'
require 'time'

module MetaKGS
  class HTTP
    class Response
      module Cacheable

        def merge_304( res )
          clone.merge_304! res
        end

        def merge_304!( res )
          raise "Not a 304 response: #{res}" unless Net::HTTPNotModified === res
          @response_304 = res
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

        def last_modified
          res = response_304 || response
          res.key?('Last-Modified') ? Time.httpdate( res['Last-Modified'] ) : nil
        end

        def has_last_modified?
          res = response_304 || response
          res.key? 'Last-Modified'
        end

        def etag
          res = response_304 || response
          res['ETag']
        end

        def has_etag?
          res = response_304 || response
          res.key? 'ETag'
        end

        def fresh?
          lifetime = freshness_lifetime
          has_age? && lifetime ? lifetime > age : false
        end

      private

        attr_accessor :response_304

        def date
          res = response_304 || response
          res.key?('Date') ? Time.httpdate( res['Date'] ) : nil
        end

        def has_date?
          res = response_304 || response
          res.key? 'Date'
        end
        def expires
          res = response_304 || response
          res.key?('Expires') ? Time.httpdate( res['Expires'] ) : nil
        end

        def has_expires?
          res = response_304 || response
          res.key? 'Expires'
        end

        def cache_control
          res = response_304 || response
          directives = res.get_fields 'Cache-Control'

          return unless directives

          value = {}
          directives.each do |directive|
            ( token, argument ) = directive.split '=', 2
            value[token.downcase] = argument || true unless token.empty?
          end

          [ 'max-age', 's-maxage' ].each do |token|
            next unless value.key? token
            value[token] = value[token].to_i
            value[token] -= res['Age'].to_i if res.key? 'Age'
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

