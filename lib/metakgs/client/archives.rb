require 'date'
require 'metakgs/client/paginator'

module MetaKGS
  class Client
    module Archives

      def get_archives( query = {} )
        now = Time.now.gmtime
        user = query[:user]
        year = query[:year] || now.year
        month = query[:month] || now.mon

        raise ":user is required" unless query.has_key?(:user)
        raise ":user is invalid" unless user.is_a? String and user.match(/^[a-zA-Z][a-zA-Z0-9]{0,9}$/)
        raise ":year is invalid" unless year.is_a? Integer and year >= 2000
        raise ":month is invalid" unless month.is_a? Integer and month.between?(1, 12)

        do_get_archives "archives/#{user}/#{year}/#{month}"
      end

      def do_get_archives( url )
        client = self
        content = get url

        return content unless Net::HTTPOK === content.response 

        content.define_singleton_method(:get) do |url|
          client.do_get_archives( url )
        end

        content.extend( MetaKGS::Client::Paginator )

        content
      end

      def get_games( query = {} )
        games = get_archives(query)["games"]

        if query.has_key?(:day) then
          now = Time.now

          date = Date.new(
            query[:year]  || now.year,
            query[:month] || now.mon,
            query[:day]
          )

          games.select! do |game|
            started_at = Time.parse( game["started_at"] )
            Date.parse( started_at.strftime('%Y-%m-%d') ) === date
          end
        end

        games
      end

    end
  end
end

