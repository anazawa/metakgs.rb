require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestArchives < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_archives
      VCR.use_cassette 'archives/anazawa/2014/10' do
        archives = @client.get_archives(
          :user  => 'anazawa',
          :year  => 2014,
          :month => 10
        )
        assert archives.is_a? Hash
        assert archives.is_a? MetaKGS::Client::Paginator
      end

      VCR.use_cassette 'archives/anazawa/2005/10' do
        assert_raise MetaKGS::Error::ResourceNotFound do
          @client.get_archives(
            :user  => 'anazawa',
            :year  => 2005,
            :month => 10
          )
        end
      end

      assert_raise ArgumentError do
        @client.get_archives
      end

      assert_raise ArgumentError do
        @client.get_archives :user => '1nvalid' 
      end
    end

    def test_get_games
      VCR.use_cassette 'archives/anazawa/2014/10' do
        games = @client.get_games(
          :user  => 'anazawa',
          :year  => 2014,
          :month => 10
        )
        assert games.is_a? Array
      end
    end

    def test_get_latest_rank_by_name
      VCR.use_cassette 'archives/anazawa' do
        assert_equal '1d', @client.get_latest_rank_by_name('anazawa')
      end
    end

  end
end

