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

      alias :archives :get_archives
      alias :games    :get_games

    end
  end
end

