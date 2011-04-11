$:.unshift File.expand_path("../../lib", File.dirname(__FILE__))

module SpecHelpers
  def gemfile(name)
    File.expand_path("./fixtures/#{name}.rb", File.dirname(__FILE__))
  end
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include SpecHelpers
end
