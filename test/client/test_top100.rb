require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTop100 < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_top100
      VCR.use_cassette 'top100' do
        top100 = @client.get_top100
        assert top100.is_a? Hash
      end
    end

    def test_get_top100_players
      VCR.use_cassette 'top100' do
        players = @client.get_top100_players
        assert players.is_a? Array
      end
    end

  end
end

