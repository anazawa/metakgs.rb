require 'metakgs/client/paginator'

module MetaKGS
  class Client
    module Tournaments

      def get_tournaments( query = {} )
        year = query[:year] || Time.now.gmtime.year
        raise ":year is invalid" unless year.is_a? Integer and year >= 2000
        do_get_tournaments "tournaments/#{year}"
      end

      def do_get_tournaments( url )
        client = self # XXX
        content = get url

        content.define_singleton_method(:get) do |url|
          client.do_get_tournaments( url )
        end

        content.extend( MetaKGS::Client::Paginator )

        content
      end

      def get_tournament_list( query = {} )
        get_tournaments(query)["tournaments"]
      end

    end
  end
end

