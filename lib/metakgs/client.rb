require 'json'
require 'metakgs/cache/null'
require 'metakgs/headers'
require 'metakgs/client/archives'
require 'metakgs/client/top100'
require 'metakgs/client/tournament'
require 'metakgs/client/tournaments'
require 'metakgs/version'
require 'net/http'
require 'time'
require 'uri'

module MetaKGS
  class Client

    include MetaKGS::Client::Archives
    include MetaKGS::Client::Top100
    include MetaKGS::Client::Tournament
    include MetaKGS::Client::Tournaments

    attr_reader :api_endpoint, :http, :cache, :default_headers

    def initialize( args = {} )
      @default_headers = MetaKGS::Headers.new
      @api_endpoint = URI( args[:api_endpoint] || "http://metakgs.org/api" )
      @cache = args[:cache] || MetaKGS::Cache::Null.new
      @http = Net::HTTP.new( api_endpoint.host, api_endpoint.port )
      agent = args[:user_agent] || "MetaKGS Ruby Gem #{MetaKGS::VERSION}"
    end

    def agent
      default_headers['User-Agent']
    end

    def agent=( value )
      default_headers['User-Agent'] = value
    end

    def get_body( path )
      response = get path =~ /^https?:\/\// ? path : uri_for(path)
      response && JSON.parse( response[:content] ) 
    end

    def uri_for( path )
      File.join( api_endpoint.to_s, path )
    end

    def get( url )
      cached = cache.fetch( url )

      return cached if cached and !expired? cached

      headers = default_headers.dclone
      headers['If-None-Match'] = cached[:etag] if cached
      headers['If-Modified-Since'] = cached[:last_modified] if cached

      response = http_get url, headers

      case response
      when Net::HTTPSuccess
        cache.store(url, {
          :date          => response['Date'],
          :last_modified => response['Last-Modified'],
          :etag          => response['ETag'],
          :cache_control => response.get_fields('Cache-Control'),
          :content_type  => response['Content-Type'],
          :content       => response.body,
        })
      when Net::HTTPNotModified
        cache.store(url, {
          :date          => response['Date'],
          :last_modified => response['Last-Modified'],
          :etag          => response['ETag'],
          :cache_control => response.get_fields('Cache-Control'),
          :content_type  => cached[:content_type],
          :content       => cached[:content],
        })
      else
        response.value
      end
    end

    def expired?( response )
      cache_control = response[:cache_control] || []
      max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
      !max_age || Time.now >= Time.parse(response[:date]) + max_age.to_i
    end

  private

    def http_head( url, headers = nil )
      http_request :head, url, headers
    end

    def http_get( url, headers = nil )
      http_request :get, url, headers
    end

    def http_request( method, url, headers = nil )
      http.send(
        method,
        URI( url ).path,
        headers ? headers.to_hash : default_headers.to_hash
      )
    end

  end
end

