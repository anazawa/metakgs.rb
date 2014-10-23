module MetaKGS
  class Client
    module Tournament

      def get_tournament( query = {} )
        id = query[:id]
        raise ArgumentError, ':id is required' unless query.has_key? :id
        raise ArgumentError, ':id is invalid' unless id.is_a? Integer and id > 0
        get_content "tournament/#{id}"
      end

      def get_tournament_rounds( query = {} )
        get_tournament(query)['rounds']
      end

      def get_tournament_round( query = {} )
        id = query[:id]
        round = query[:round]

        raise ArgumentError, ':id is required' unless query.has_key? :id
        raise ArgumentError, ':round is required' unless query.has_key? :round
        raise ArgumentError, ':id is invalid' unless id.is_a? Integer and id > 0
        raise ArgumentError, ':round is invalid' unless round.is_a? Integer and round > 0

        get_content "tournament/#{id}/round/#{round}"
      end

      def get_tournament_games( query = {} )
        get_tournament_round(query)['games']
      end

      def get_tournament_byes( query = {} )
        get_tournament_round(query)['byes']
      end

      def get_tournament_entrants( query = {} )
        id = query[:id]
        raise ArgumentError, ':id is required' unless query.has_key? :id
        raise ArgumentError, ':id is invalid' unless id.is_a? Integer and id > 0
        get_content "tournament/#{id}/entrants"
      end

      def get_tournament_entrant_list( query = {} )
        get_tournament_entrants(query)['entrants']
      end

      alias :tourn              :get_tournament
      alias :tourn_rounds       :get_tournament_rounds
      alias :tourn_round        :get_tournament_round
      alias :tourn_byes         :get_tournament_byes
      alias :tourn_games        :get_tournament_games
      alias :tourn_entrants     :get_tournament_entrants
      alias :tourn_entrant_list :get_tournament_entrant_list

    end
  end
end

