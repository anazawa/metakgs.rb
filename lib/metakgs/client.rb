require 'metakgs/archives'
require 'metakgs/client/archives'
require 'net/http'
require 'json'
require 'uri'

module MetaKGS
  class Client
    include MetaKGS::Client::Archives

    def api_endpoint
      "http://metakgs.org/api"
    end

    def get( url )
      url = api_endpoint + "/#{url}" unless url.match(/^https?:\/\//)
      response = Net::HTTP.get_response( URI.parse(url) )
      response.value unless Net::HTTPSuccess === response
      JSON.parse( response.body )
    end

  end
end

