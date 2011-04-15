require 'spec_helper'

describe Gemphile, "POST /push" do
  include Rack::Test::Methods

  it "calls Repository.from_payload" do
    Repository.expects(:from_payload).once
    post '/push', :payload => payload('initial_push')
  end
end

