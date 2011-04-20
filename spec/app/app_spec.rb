require 'spec_helper'

describe Gemphile::App do
  include Rack::Test::Methods

  describe "GET /search" do
    context "with an exact match" do
      it "should redirect on an exact match" do
        Factory(:gem_entry, name: 'gemphile')

        get '/search', :q => 'gemphile-gem'
        last_response.should be_redirect
      end
    end

    context "with a partial match" do
      it "should present a list of matches" do
        Factory(:gem_entry, name: 'gemphile')

        get '/search', :q => 'gem'
        last_response.should be_ok
        last_response.body.should match(/could not be found/)
      end
    end
  end

  describe "POST /push" do
    it "calls Repository.from_payload and enqueues a GemfileJob" do
      Repository.expects(:from_payload).once.returns(Repository.new)
      post '/push', :payload => github('push/initial_push')
      last_response.should be_ok
    end

    it "returns 500 when given a bad payload" do
      post '/push', :payload => ""
      last_response.should_not be_ok
    end
  end

  describe "POST /add" do
    it "ignores invalid usernames" do
      post '/add', :repo => '-tsigo'
      last_response.should_not be_ok
    end

    it "ignores invalid repositories" do
      post '/add', :repo => 'tsigo/gemphile/production'
      last_response.should_not be_ok
    end

    it "recognizes a user name" do
      Delayed::Job.expects(:enqueue).with { |v| v.is_a?(UserJob) }
      post '/add', :repo => 'tsigo'
      last_response.should be_ok
    end

    it "recognizes a repository" do
      Delayed::Job.expects(:enqueue).with { |v| v.is_a?(RepositoryJob) }
      post '/add', :repo => 'tsigo/gemphile'
      last_response.should be_ok
    end
  end
end
