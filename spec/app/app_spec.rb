require 'spec_helper'

describe Gemphile::App do
  describe "POST /push" do
    include Rack::Test::Methods

    it "calls Repository.from_payload and enqueues a GemfileJob" do
      Repository.expects(:from_payload).once.returns(Repository.new)
      post '/push', :payload => github('initial_push')
      last_response.should be_ok
    end

    it "returns 500 when given a bad payload" do
      post '/push', :payload => ""
      last_response.should_not be_ok
    end
  end
end
