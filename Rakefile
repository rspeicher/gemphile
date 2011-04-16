require 'rspec/core/rake_task'

task :default => :spec

desc "Run Gemphile specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./spec/**/*_spec.rb"]
end

desc "Run GemfileReader specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./vendor/gemfile_reader/spec/**/*_spec.rb"]
end

namespace :jobs do
  task :environment do
    require_relative 'app/libraries'
  end

  desc "Clear the delayed_job queue."
  task :clear => [:environment] do
    Delayed::Job.delete_all
  end

  desc "Start a delayed_job worker."
  task :work => [:environment] do
    Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end
end
