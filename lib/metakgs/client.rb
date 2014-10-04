require 'json'
require 'metakgs/client/archives'
require 'metakgs/client/top100'
require 'metakgs/version'
require 'net/http'
require 'uri'

module MetaKGS
  class Client

    include MetaKGS::Client::Archives
    include MetaKGS::Client::Top100

    attr_reader :api_endpoint, :http
    attr_accessor :user_agent

    def initialize( args = {} )
      @user_agent = args[:user_agent] || "MetaKGS Ruby Gem #{MetaKGS::VERSION}"
      @api_endpoint = URI( args[:api_endpoint] || "http://metakgs.org/api" )
      @http = Net::HTTP.new( api_endpoint.host, api_endpoint.port )
    end

    def get( path )
      response = do_get path =~ /^https?:\/\// ? URI(path) : uri_for(path)
      response.value unless Net::HTTPSuccess === response
      JSON.parse( response.body )
    end

    def do_get( url )
      http.get(url.path, {
        'User-Agent' => user_agent,
      })
    end

    def uri_for( path )
      URI( File.join(api_endpoint.to_s, path) )
    end

  end
end

