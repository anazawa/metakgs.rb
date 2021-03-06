module MetaKGS
  class Client
    module Tournaments

      # http://metakgs.org/docs#get-api-tournaments
      def get_tournaments( query = {} )
        year = query[:year]

        return get_content 'tournaments' unless query.key? :year

        unless year.is_a? Integer and year >= 2000
          raise ArgumentError, ":year is invalid: '#{year}'"
        end

        get_content "tournaments/#{year}"
      end

      alias :tourns :get_tournaments

      def get_tournament_list( query = {} )
        get_tournaments(query)['tournaments']
      end

      alias :tourn_list :get_tournament_list

    end
  end
end

