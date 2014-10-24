require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournament < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
      VCR.insert_cassette 'tournament'
    end

    def teardown
      VCR.eject_cassette
    end

    def test_get_tournament
      tourn = @client.get_tournament :id => 123
      assert tourn.is_a? Hash

      assert_raise ArgumentError do
        @client.get_tournament
      end

      assert_raise ArgumentError do
        @client.get_tournament :id => 'invalid'
      end
    end

    def test_get_tournament_round
      tourn_rounds = @client.get_tournament_rounds :id => 123
      assert tourn_rounds.is_a? Array
    end

  end
end

