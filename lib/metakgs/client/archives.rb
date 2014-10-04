module MetaKGS
  class Client
    module Archives

      def get_archives( query = {} )
        (get MetaKGS::Archives.build_path(query))["content"]
      end

      def paginate_archives( query = {} )
        do_paginate_archives MetaKGS::Archives.build_path( query )
      end

      def do_paginate_archives( url )
        archives = get url
        link = archives["link"]
        content = archives["content"]
        outer = self # XXX

        content.define_singleton_method(:has_next?) do
          !link["next"].nil?
        end

        content.define_singleton_method(:next) do
          has_next? && outer.do_paginate_archives( link["next"] )
        end

        content.define_singleton_method(:has_prev?) do
          !link["prev"].nil?
        end

        content.define_singleton_method(:prev) do
          has_prev? && outer.do_paginate_archives( link["prev"] )
        end

        content.define_singleton_method(:first) do
          outer.do_paginate_archives( link["first"] )
        end

        content.define_singleton_method(:last) do
          outer.do_paginate_archives( link["last"] )
        end

        content
      end

    end
  end
end

