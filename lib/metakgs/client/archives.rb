module MetaKGS
  class Client
    module Archives

      def get_archives( query = {} )
        now = Time.now.gmtime
        user = query[:user]
        year = query[:year] || now.year
        month = query[:month] || now.mon

        raise ArgumentError, ':user is required' unless query.has_key?(:user)
        raise ArgumentError, ':user is invalid' unless user.is_a? String and user =~ /^[a-zA-Z][a-zA-Z0-9]{0,9}$/
        raise ArgumentError, ':year is invalid' unless year.is_a? Integer and year >= 2000
        raise ArgumentError, ':month is invalid' unless month.is_a? Integer and month.between?(1, 12)

        get_content "archives/#{user}/#{year}/#{month}"
      end

      def get_games( query = {} )
        get_archives(query)['games']
      end

      def get_latest_rank_by_name( name )
        archives = get_archives :user => name
        rank = nil

        while archives and rank.nil?
          game = archives['games'].first
          if game and game['owner']
            rank = game['owner']['rank'] || ''
          elsif game
            players = [ *game['black'], *game['white'] ]
            rank = players.find { |player| player['name'] == name }['rank']
            rank ||= ''
          else
            archives = archives.prev
          end
        end

        rank
      end

      alias :archives :get_archives
      alias :games    :get_games

    end
  end
end

