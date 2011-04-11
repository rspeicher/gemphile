$:.unshift File.expand_path("../../lib", File.dirname(__FILE__))

require 'gemfile_reader'

module SpecHelpers
  def gemfile(name)
    File.read(File.expand_path("./fixtures/#{name}.rb", File.dirname(__FILE__)))
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
end
