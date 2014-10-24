require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournaments < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_tournaments
      VCR.use_cassette 'tournaments/2005' do
        tourns = @client.get_tournaments :year => 2005
        assert tourns.is_a? Hash
      end

      assert_raise ArgumentError do
        @client.get_tournaments :year => 'invalid'
      end
    end

    def test_get_tournament_list
      VCR.use_cassette 'tournaments/2005' do
        tourn_list = @client.get_tournament_list :year => 2005
        assert tourn_list.is_a? Array
      end
    end

  end
end

