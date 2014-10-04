module MetaKGS
  class Client
    module Top100

      def get_top100
        (get "top100")["content"]
      end

    end
  end
end
