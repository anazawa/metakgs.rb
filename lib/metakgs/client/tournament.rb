require 'metakgs/client/tournament/paginator'

module MetaKGS
  class Client
    module Tournament

      def get_tournament( query = {} )
        id = query[:id]
        raise ":id is required" unless query.has_key?(:id)
        raise ":id is invalid" unless id.is_a? Integer and id > 0
        do_get_tournament "tournament/#{id}"
      end

      def do_get_tournament( url )
        body = get_body url
        body && body["content"]
      end

      def get_tournament_rounds( query = {} )
        content = get_tournament query
        content && content["rounds"]
      end

      def get_tournament_round( query = {} )
        id = query[:id]
        round = query[:round]

        raise ":id is required" unless query.has_key?(:id)
        raise ":round is required" unless query.has_key?(:round)
        raise ":id is invalid" unless id.is_a? Integer and id > 0
        raise ":round is invalid" unless round.is_a? Integer and round > 0

        do_get_tournament_round "tournament/#{id}/round/#{round}"
      end

      def do_get_tournament_round( url )
        client = self
        body = get_body url
        content = body && body["content"]
        round = content && content["round"]
        rounds = content && content["rounds"]

        return unless body

        content.define_singleton_method(:round) { round }
        content.define_singleton_method(:rounds) { rounds }
        content.define_singleton_method(:get) { |url| client.do_get_tournament_round(url) }
        content.extend( MetaKGS::Client::Tournament::Paginator )

        content
      end

      def get_tournament_games( query = {} )
        content = get_tournament_round query
        content && content["games"]
      end

      def get_tournament_byes( query = {} )
        content = get_tournament_round query
        content && content["byes"]
      end

      def get_tournament_entrants( query = {} )
        id = query[:id]
        raise ":id is required" unless query.has_key?(:id)
        raise ":id is invalid" unless id.is_a? Integer and id > 0
        do_get_tournament_entrants "tournament/#{id}/entrants"
      end

      def do_get_tournament_entrants( url )
        body = get_body url
        body && body["content"]
      end

      def get_tournament_entrant_list( url )
        content = get_tournament_entrants url
        content && content["entrants"]
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
