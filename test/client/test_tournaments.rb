require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournaments < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
      VCR.insert_cassette 'tournaments'
    end

    def teardown
      VCR.eject_cassette
    end

    def test_get_tournaments
      tourns = @client.get_tournaments
      assert tourns.is_a? Hash

      assert_raise ArgumentError do
        @client.get_tournaments :year => 'invalid'
      end
    end

    def test_get_tournament_list
      tourn_list = @client.get_tournament_list
      assert tourn_list.is_a? Array
    end

  end
end

