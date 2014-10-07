require 'metakgs/client/paginator'

module MetaKGS
  class Client
    module Tournaments

      # http://metakgs.org/docs#get-api-tournaments
      def get_tournaments( query = {} )
        year = query[:year] || Time.now.gmtime.year
        raise ":year is invalid" unless year.is_a? Integer and year >= 2000
        do_get_tournaments "tournaments/#{year}"
      end

      def do_get_tournaments( url )
        client = self
        body = get_body url
        content = body && body["content"]
        link = body && body["link"]

        return unless body

        content.define_singleton_method(:link) { link }
        content.define_singleton_method(:get) { |url| client.do_get_tournaments(url) }
        content.extend( MetaKGS::Client::Paginator )

        content
      end

      def get_tournament_list( query = {} )
        content = get_tournaments query
        content && content["tournaments"]
      end

      alias :get_tourns     :get_tournaments
      alias :get_tourn_list :get_tournament_list

      alias :tourns     :get_tournaments
      alias :tourn_list :get_tournament_list

    end
  end
end

