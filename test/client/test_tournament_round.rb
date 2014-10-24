require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournamentRound < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
      VCR.insert_cassette 'tournament/round'
    end

    def teardown
      VCR.eject_cassette
    end

    def test_get_tournament_round
      tourn_round = @client.get_tournament_round :id => 123, :round => 1
      assert tourn_round.is_a? Hash

      assert_raise ArgumentError do
        @client.get_tournament_round :id => 123
      end

      assert_raise ArgumentError do
        @client.get_tournament_round :id => 123, :round => 'invalid'
      end
    end

    def test_get_tournament_games
      tourn_games = @client.get_tournament_games :id => 123, :round => 1
      assert tourn_games.is_a? Array
    end

    def test_get_tournament_byes
      tourn_byes = @client.get_tournament_byes :id => 123, :round => 1
      assert tourn_byes.is_a? Array
    end

  end
end

