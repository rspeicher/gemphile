require 'spec_helper'

describe UserJob do
  let(:job) { UserJob.new('tsigo') }

  it "should pass fetched data on to Repository.from_user" do
    stub_request(:get, "http://github.com/api/v2/json/repos/show/tsigo").to_return(:status => 200, :body => "data", :headers => {})
    Repository.expects(:from_user).with('data')
    job.perform
  end
end
