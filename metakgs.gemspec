lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metakgs/version'

Gem::Specification.new do |gem|
  gem.name        = 'metakgs'
  gem.version     = MetaKGS::VERSION
  gem.date        = '2014-10-05'
  gem.summary     = 'MetaKGS client'
  gem.description = 'CLI and Ruby client library for MetaKGS'
  gem.authors     = [ "Ryo Anazawa" ]
  gem.email       = [ 'anazawa@cpan.org' ]
  gem.files       = `git ls-files`.split($/)
  gem.homepage    = "https://github.com/anazawa/metakgs.rb"
  gem.license     = 'MIT'
end

