module MetaKGS
  class Client
    module Top100

      def get_top100
        get "top100"
      end

      def get_top100_players
        get_top100["players"]
      end

    end
  end
end
