ENV['RACK_ENV'] = 'test'

$:.unshift(File.expand_path('..', File.dirname(__FILE__)))

require_relative '../app/app'
require_relative 'factories'

require 'database_cleaner'
require 'fakeweb'
require 'rack/test'

module SpecHelpers
  def app
    Gemphile::App
  end

  def gemfile(name)
    File.read(File.expand_path("./fixtures/gemfile_payloads/#{name}.json", File.dirname(__FILE__)))
  end

  def github(name)
    File.read(File.expand_path("./fixtures/github/#{name}.json", File.dirname(__FILE__)))
  end
end

RSpec.configure do |config|
  config.mock_with :mocha

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include SpecHelpers

  config.before(:suite) do
    FakeWeb.allow_net_connect = false

    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
