require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTop100 < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
      VCR.insert_cassette 'top100'
    end

    def teardown
      VCR.eject_cassette
    end

    def test_get_top100
      top100 = @client.get_top100
      assert top100.is_a? Hash
    end

    def test_get_top100_players
      players = @client.get_top100_players
      assert players.is_a? Array
    end

  end
end

