$:.unshift File.expand_path("../../lib", File.dirname(__FILE__))

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include SpecHelpers
end
