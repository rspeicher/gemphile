$:.unshift File.expand_path("../..", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

ENV['RACK_ENV'] = 'test'

require 'gemphile'

require 'database_cleaner'
require 'fakeweb'
require 'rack/test'

module SpecHelpers
  def gemfile(name)
    File.read(File.expand_path("./fixtures/gemfiles/#{name}.rb", File.dirname(__FILE__)))
  end

  # Assumes `let(:gems)` has been defined
  def find_gem(name, index = 0)
    return unless gems
    gems.find_all { |g| g.name == name }[index]
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
