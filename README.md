# MetaKGS

[![Build Status](https://travis-ci.org/anazawa/metakgs.rb.svg)](https://travis-ci.org/anazawa/metakgs.rb)

Ruby toolkit for working with the MetaKGS API

## Prerequisite

- Ruby 1.9 or later
- Bundler

## Installation

    git clone git://github.com/anazawa/metakgs.rb.git
    bundle && bundle exec rake install

## Usage

    require 'metakgs/client'

    client = MetaKGS::Client.new(
      :user_agent => 'YourAgent/0.0.1'
    )

    # KGS Game Archives
    archives = client.get_archives(
      :user  => 'foo',
      :year  => 2014,
      :month => 10
    )

    # Top 100 Players
    top100 = client.get_top100

    # List of KGS Tornaments 
    tourns = client.get_tournaments(
      :year => 2014
    )

    # Information for the tournament
    tourn = client.get_tournament(
      :id => 123
    )

    # Tournament Entrants
    tourn_entrants = client.get_tournament_entrants(
      :id => 123
    )

    # Tournament Rounds
    tourn_rounds = client.get_tournament_rounds(
      :id    => 123,
      :round => 1
    )

## Shortcuts

    archives -> get_archives
    games    -> get_archives["games"]

    top100         -> get_top100
    top100_players -> get_top100["players"]

    tourns     -> get_tournaments
    tourn_list -> get_tournaments["tournaments"]

    tourn        -> get_tournament
    tourn_rounds -> get_tournament["rounds"]

    tourn_round -> get_tournament_round
    tourn_games -> get_tournament_round["games"]
    tourn_byes  -> get_tournament_round["byes"]

    tourn_entrants     -> get_tournament_entrants
    tourn_entrant_list -> get_tournament_entrants["entrants"]

## Contributing

1. Fork it ( https://github.com/anazawa/metakgs.rb/fork )
2. Create your feature branch (`git checkout -b my-new-branch`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## See Also

[MetaKGS](http://metakgs.org) - Unofficial JSON API for KGS Go Server

## Copyright

Ryo Anazawa

## License

This software is licensed under the MIT License.

