require 'spec_helper'

describe GemfileJob do
  it "should be queued from a new repository" do
    GemfileJob.expects(:new).with(anything()).returns(stub(perform: true))
    Repository.from_payload(github('push/initial_push'))
  end

  it "should be queued from an existing repository with Gemfile changes" do
    repo = Repository.from_payload(github('push/initial_push'))

    GemfileJob.expects(:new).with(repo.id).twice.returns(stub(perform: true))

    Repository.from_payload(github('push/add_gemfile'))
    Repository.from_payload(github('push/modify_gemfile'))

    Delayed::Job.count.should eql(3)
  end
end
