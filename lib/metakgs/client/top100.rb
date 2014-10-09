module MetaKGS
  class Client
    module Top100

      def get_top100
        body = get_json 'top100'
        body && body['content']
      end

      def get_top100_players
        content = get_top100
        content && content['players']
      end

      alias :top100         :get_top100
      alias :top100_players :get_top100_players

    end
  end
end
