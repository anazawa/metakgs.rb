require 'json'
require 'metakgs/cache/file'
require 'metakgs/client/archives'
require 'metakgs/client/top100'
require 'metakgs/client/tournament'
require 'metakgs/client/tournaments'
require 'metakgs/version'
require 'net/http'
require 'uri'

module MetaKGS
  class Client

    include MetaKGS::Client::Archives
    include MetaKGS::Client::Top100
    include MetaKGS::Client::Tournament
    include MetaKGS::Client::Tournaments

    ONE_YEAR = 31556930

    attr_reader :api_endpoint, :http, :cache
    attr_accessor :user_agent

    def initialize( args = {} )
      @user_agent = args[:user_agent] || "MetaKGS Ruby Gem #{MetaKGS::VERSION}"
      @api_endpoint = URI( args[:api_endpoint] || "http://metakgs.org/api" )
      @cache = args[:cache] || MetaKGS::Cache::File.new
      @http = Net::HTTP.new( api_endpoint.host, api_endpoint.port )
    end

    def http_get( url )
      http.get(URI(url).path, {
        'User-Agent' => user_agent,
      })
    end

    def get_body( path )
      response = get path =~ /^https?:\/\// ? path : uri_for(path)
      Net::HTTPSuccess === response ? JSON.parse(response.body) : nil
    end

    def uri_for( path )
      File.join( api_endpoint.to_s, path )
    end

    def get( url )
      cached = cache.get( url )
      response = cached || http_get( url )
      is_cached = cached ? true : false

      cache.set( url, response, expires_at(response) ) if !cached and should_cache?(response)
      response.define_singleton_method(:cached?) { is_cached }

      response
    end

    def expires_at( response )
      cache_control = response.get_fields('Cache-Control') || []
      max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
      max_age ? Time.now + max_age.to_i : Time.now + ONE_YEAR
    end

    def should_cache?( response )
      Net::HTTPSuccess === response
    end

  end
end

