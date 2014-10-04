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
        archives = get url
        link = archives["link"]
        content = archives["content"]
        outer = self # XXX

        content.define_singleton_method(:has_next?) do
          !link["next"].nil?
        end

        content.define_singleton_method(:next) do
          has_next? && outer.do_get_archives( link["next"] )
        end

        content.define_singleton_method(:has_prev?) do
          !link["prev"].nil?
        end

        content.define_singleton_method(:prev) do
          has_prev? && outer.do_get_archives( link["prev"] )
        end

        content.define_singleton_method(:first) do
          outer.do_get_archives( link["first"] )
        end

        content.define_singleton_method(:last) do
          outer.do_get_archives( link["last"] )
        end

        content
      end

    end
  end
end

