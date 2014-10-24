require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournament < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_tournament
      VCR.use_cassette 'tournament/123' do
        tourn = @client.get_tournament :id => 123
        assert tourn.is_a? Hash
      end

      VCR.use_cassette 'tournament/12345' do
        assert_raise MetaKGS::Error::ResourceNotFound do
          @client.get_tournament :id => 12345
        end
      end

      assert_raise ArgumentError do
        @client.get_tournament
      end

      assert_raise ArgumentError do
        @client.get_tournament :id => 'invalid'
      end
    end

    def test_get_tournament_round
      VCR.use_cassette 'tournament/123' do
        tourn_rounds = @client.get_tournament_rounds :id => 123
        assert tourn_rounds.is_a? Array
      end
    end

  end
end

