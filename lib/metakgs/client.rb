require 'json'
require 'metakgs/cache/null'
require 'metakgs/http/header'
require 'metakgs/http/response'
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

    attr_accessor :cache
    attr_reader :api_endpoint

    def initialize( args = {} )
      @api_endpoint = URI( args[:api_endpoint] || "http://metakgs.org/api" )
      self.cache = args[:cache] || MetaKGS::Cache::Null.new
      self.default_header = args[:default_header] if args[:default_header]
      self.agent = args[:agent] if args.has_key?( :agent )
    end

    def default_header
      @default_header ||= MetaKGS::HTTP::Header.new({
        'User-Agent' => "MetaKGS Ruby Gem #{MetaKGS::VERSION}",
      })
    end

    def default_header=( value )
      @default_header = MetaKGS::HTTP::Header.new( value )
    end

    def agent
      default_header['User-Agent']
    end

    def agent=( value )
      default_header['User-Agent'] = value
    end

    def get_body( path )
      response = get path =~ /^https?:\/\// ? path : uri_for(path)
      response && response.body
    end

    def uri_for( path )
      File.join( api_endpoint.to_s, path )
    end

    def get( url )
      cached = cache.fetch url

      return cached if cached and !cached.expired?

      header = default_header.dclone
      header['If-None-Match'] = cached.etag if cached
      header['If-Modified-Since'] = cached.last_modified.httpdate if cached

      response = http_get url, header

      case response
      when Net::HTTPSuccess
        cache.store url, build_response(response)
      when Net::HTTPNotModified
        cache.store url, cached.merge(response)
      else
        response.value
      end
    end

  private

    def build_response( response )
      MetaKGS::HTTP::Response.new( response )
    end

    def http
      @http ||= Net::HTTP.new( api_endpoint.host, api_endpoint.port )
    end

    def http_get( url, header = nil )
      http_request :get, url, header
    end

    def http_request( method, url, header = nil )
      http.send(
        method,
        URI( url ).path,
        header ? header.to_hash : default_header.to_hash
      )
    end

  end
end

