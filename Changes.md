## 0.0.6 Dec 22nd, 2014

- #get_latest_rank_by_name does not depend on the case of the given name
  (Ellyster) #1

## 0.0.5 Oct 25th, 2014

- add unit tests
- tests require 'test-unit', 'vcr', 'webmock' and 'timecop'
- add Travis CI status image to README.md
- rake task defaults to 'test'
- add Cache::Memory
- Cache::Null inherits from Cache properly

## 0.0.4 Oct 23rd, 2014

- add #get_latest_rank_by_name
- #get_archives raise ArgumentError
- #get_tuornament raise ArgumentError
- #get_tuornament_round raise ArgumentError
- #get_tuornament_entrants raise ArgumentError
- remove client/tournament/paginator
- replace #get_json with #get_content
- HTTP::Response is a module
- add Error::ParsingError

## 0.0.3 Oct 20th, 2014

### MetaKGS::Client

- #get raise TimeoutError when 202

### MetaKGS::Cache

- rename #do_fetch to #fetch_object
- rename #do_store to #store_object
- rename #do_key to #object_keys
- rename #do_delete to #delete_object

### MetaKGS::Cache::File

- write atomically

## 0.0.2 Oct 12th, 2014

- add metakgs/cache/null. #cache defaults to MetaKGS::Cache::Null
- add #logger, #shared_cache, #read_timeout, #open_timeout and #default_header
- #get_body was replaced with #get_json
- add metakgs/error
- add metakgs/http/header and response
- conditional GET support

## 0.0.1 Oct 8th, 2014

- initial version

