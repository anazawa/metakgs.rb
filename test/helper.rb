require 'vcr'

VCR.configure do |c|
  c.default_cassette_options = {
  }

  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

