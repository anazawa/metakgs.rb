require 'json'
require 'metakgs/cache/file'
require 'metakgs/client/archives'
require 'metakgs/client/top100'
require 'metakgs/client/tournaments'
require 'metakgs/version'
require 'net/http'
require 'uri'

module MetaKGS
  class Client

    include MetaKGS::Client::Archives
    include MetaKGS::Client::Top100
    include MetaKGS::Client::Tournaments

    attr_reader :api_endpoint, :http, :cache
    attr_accessor :user_agent

    def initialize( args = {} )
      @user_agent = args[:user_agent] || "MetaKGS Ruby Gem #{MetaKGS::VERSION}"
      @api_endpoint = URI( args[:api_endpoint] || "http://metakgs.org/api" )
      @cache = args[:cache] || MetaKGS::Cache.new
      @http = Net::HTTP.new( api_endpoint.host, api_endpoint.port )
    end

    def get( path )
      response = do_get path =~ /^https?:\/\// ? URI(path) : uri_for(path)
      response.value unless Net::HTTPSuccess === response
      JSON.parse( response.body )
    end

    def do_get( url )
      cached = cache.get( url.to_s )

      return cached if cached

      response = http.get(url.path, {
        'User-Agent' => user_agent,
      })

      cache.set( url.to_s, response ) if Net::HTTPSuccess === response

      response
    end

    def uri_for( path )
      URI( File.join(api_endpoint.to_s, path) )
    end

  end
end

