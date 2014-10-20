### 0.0.3 Oct 20th, 2014

## MetaKGS::Client

- #get raise TimeoutError when 202

## MetaKGS::Cache

- rename #do_fetch to #fetch_object
- rename #do_store to #store_object
- rename #do_key to #object_keys
- rename #do_delete to #delete_object

## MetaKGS::Cache::File

- write atomically

### 0.0.2 Oct 12th, 2014

- add metakgs/cache/null. #cache defaults to MetaKGS::Cache::Null
- add #logger, #shared_cache, #read_timeout, #open_timeout and #default_header
- #get_body was replaced with #get_json
- add metakgs/error
- add metakgs/http/header and response
- conditional GET support

### 0.0.1 Oct 8th, 2014

- initial version

