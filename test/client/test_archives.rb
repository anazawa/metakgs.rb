require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestArchives < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
      VCR.insert_cassette 'archives'
    end

    def teardown
      VCR.eject_cassette
    end

    def test_get_archives
      archives = @client.get_archives :user => 'anazawa'
      assert archives.is_a? Hash
      assert archives.is_a? MetaKGS::Client::Paginator

      assert_raise ArgumentError do
        @client.get_archives
      end

      assert_raise ArgumentError do
        @client.get_archives :user => '1nvalid' 
      end
    end

    def test_get_games
      games = @client.get_games :user => 'anazawa'
      assert games.is_a? Array
    end

    def test_get_latest_rank_by_name
      assert_equal '1d', @client.get_latest_rank_by_name('anazawa')
    end

  end
end

