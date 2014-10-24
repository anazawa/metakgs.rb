require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournamentRound < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_tournament_round
      VCR.use_cassette 'tournament/123/round/1' do
        tourn_round = @client.get_tournament_round :id => 123, :round => 1
        assert tourn_round.is_a? Hash
      end

      assert_raise ArgumentError do
        @client.get_tournament_round :id => 123
      end

      assert_raise ArgumentError do
        @client.get_tournament_round :id => 123, :round => 'invalid'
      end
    end

    def test_get_tournament_games
      VCR.use_cassette 'tournament/123/round/1' do
        tourn_games = @client.get_tournament_games :id => 123, :round => 1
        assert tourn_games.is_a? Array
      end
    end

    def test_get_tournament_byes
      VCR.use_cassette 'tournament/123/round/1' do
        tourn_byes = @client.get_tournament_byes :id => 123, :round => 1
        assert tourn_byes.is_a? Array
      end
    end

  end
end

