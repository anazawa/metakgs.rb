require 'test/unit'
require 'metakgs/client'
require File.expand_path '../../helper', __FILE__

module Client
  class TestTournamentEntrants < Test::Unit::TestCase

    def setup
      @client = MetaKGS::Client.new
      @client.logger.level = Logger::WARN
    end

    def test_get_tournament_entrants
      VCR.use_cassette 'tournament/123/entrants' do
        tourn_entrants = @client.get_tournament_entrants :id => 123
        assert tourn_entrants.is_a? Hash
      end
    end

    def test_get_tournament_entrant_list
      VCR.use_cassette 'tournament/123/entrants' do
        tourn_entrant_list = @client.get_tournament_entrant_list :id => 123
        assert tourn_entrant_list.is_a? Array
      end
    end

  end
end

