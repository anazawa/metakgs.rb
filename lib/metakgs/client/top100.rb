module MetaKGS
  class Client
    module Top100

      def get_top100
        get_content 'top100'
      end

      def get_top100_players
        get_top100['players']
      end

      alias :top100         :get_top100
      alias :top100_players :get_top100_players

    end
  end
end

