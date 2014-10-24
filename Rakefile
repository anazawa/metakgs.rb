require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = Dir.glob 'test/**/*.rb'
  t.warning = true
  t.verbose = true
end

