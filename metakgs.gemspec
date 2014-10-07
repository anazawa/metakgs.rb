lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metakgs/version'

Gem::Specification.new do |gem|
  gem.name = 'metakgs'
  gem.version = MetaKGS::VERSION
  gem.date = '2014-10-05'
  gem.summary = 'Ruby toolkit for working with the MetaKGS API'
  gem.description = 'Simple wrapper for the MetaKGS API'
  gem.files = %( Rakefile metakgs.gemspec )
  gem.homepage = "https://github.com/anazawa/metakgs.rb"
  gem.licenses = [ 'MIT' ]
  gem.required_ruby_version = '>= 1.9.2'
  gem.authors = [ "Ryo Anazawa" ]
  gem.email = [ 'anazawa@cpan.org' ]
end

