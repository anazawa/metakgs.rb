module MetaKGS
  class Client
    module Tournament
      module Paginator

        def round
          raise "call to abstract method 'round'"
        end

        def rounds
          raise "call to abstract method 'rounds'"
        end

        def get( url )
          raise "call to abstract method 'get'"
        end

        def has_next?
          !rounds[round].nil?
        end

        def next
          has_next? && get(rounds[round]["url"])
        end

        def has_prev?
          round > 1
        end

        def prev
          has_prev? && get(rounds[round-2]["url"])
        end

        def first
          get rounds[0]["url"]
        end

        def last
          get rounds[-1]["url"]
        end

      end
    end
  end
end

