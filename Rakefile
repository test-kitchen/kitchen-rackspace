# Encoding: UTF-8

require 'bundler/setup'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'

Cane::RakeTask.new

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: [:cane, :rubocop, :spec]
