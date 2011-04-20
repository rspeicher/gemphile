require 'spec_helper'

describe RepositoryJob do
  let(:job) { RepositoryJob.new('tsigo/gemphile') }

  it "should pass fetched data on to Repository.from_user" do
    stub_request(:get, "http://github.com/api/v2/json/repos/show/tsigo/gemphile").to_return(:status => 200, :body => "data", :headers => {})
    Repository.expects(:from_payload).with('data')
    job.perform
  end
end
