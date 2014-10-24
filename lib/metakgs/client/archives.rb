module MetaKGS
  class Client
    module Archives

      def get_archives( query = {} )
        user = query[:user]
        year = query[:year]
        month = query[:month] 

        raise ArgumentError, ':user is required' unless query.key? :user

        unless user.is_a? String and user =~ /^[a-zA-Z][a-zA-Z0-9]{0,9}$/
          raise ArgumentError, ":user is invalid: '#{user}'"
        end

        return get_content "archives/#{user}" unless query.key? :year

        unless year.is_a? Integer and year >= 2000
          raise ArgumentError, ":year is invalid: '#{year}'"
        end

        return get_content "archives/#{user}/#{year}" unless query.key? :month

        unless month.is_a? Integer and month.between?(1, 12)
          raise ArgumentError, ":month is invalid: '#{month}'"
        end

        get_content "archives/#{user}/#{year}/#{month}"
      end

      alias :archives :get_archives

      def get_games( query = {} )
        get_archives(query)['games']
      end

      alias :games :get_games

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

    end
  end
end

