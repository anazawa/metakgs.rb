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
        raise ":user is invalid" unless user.is_a? String and user =~ /^[a-zA-Z][a-zA-Z0-9]{0,9}$/
        raise ":year is invalid" unless year.is_a? Integer and year >= 2000
        raise ":month is invalid" unless month.is_a? Integer and month.between?(1, 12)

        do_get_archives "archives/#{user}/#{year}/#{month}"
      end

      def do_get_archives( url )
        client = self
        body = get_body url
        content = body && body["content"]
        link = body && body["link"]

        return unless body

        content.define_singleton_method(:link) { link }
        content.define_singleton_method(:get) { |url| client.do_get_archives(url) }
        content.extend( MetaKGS::Client::Paginator )

        content
      end

      def get_games( query = {} )
        content = get_archives query
        content && content["games"]
      end

      alias :archives :get_archives
      alias :games    :get_games

    end
  end
end

