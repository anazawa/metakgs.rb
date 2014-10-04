module MetaKGS
  class Client
    module Tournaments

      def get_tournaments( query = {} )
        year = query[:year] || Time.now.gmtime.year
        raise ":year is invalid" unless year.is_a? Integer and year >= 2000
        do_get_tournaments "tournaments/#{year}"
      end

      def do_get_tournaments( url )
        response = get url
        link = response["link"]
        tournaments = response["content"]["tournaments"]
        outer = self # XXX

        tournaments.define_singleton_method(:has_next?) do
          !link["next"].nil?
        end

        tournaments.define_singleton_method(:next) do
          has_next? && outer.do_get_tournaments( link["next"] )
        end

        tournaments.define_singleton_method(:has_prev?) do
          !link["prev"].nil?
        end

        tournaments.define_singleton_method(:prev) do
          has_prev? && outer.do_get_tournaments( link["prev"] )
        end

        tournaments.define_singleton_method(:first) do
          outer.do_get_tournaments( link["first"] )
        end

        tournaments.define_singleton_method(:last) do
          outer.do_get_tournaments( link["last"] )
        end

        tournaments
      end

    end
  end
end

