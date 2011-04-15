require 'spec_helper'

describe Repository, "#from_payload" do
  context "given invalid or private data" do
    it "ignores payloads without repository info" do
      payload = %{{"name": "repo"}}
      expect { Repository.from_payload(payload) }.to_not change(Repository, :count)
    end

    it "ignores private repositories" do
      expect { Repository.from_payload(payload('private_repo')) }.to_not change(Repository, :count)
    end
  end

  context "given valid data" do
    let(:repo) { Repository.from_payload(payload('initial_push')) }

    it "extracts owner name" do
      repo.owner.should eql('tsigo')
    end

    it "sets name" do
      repo.name.should eql('hook_test')
    end

    it "sets description" do
      repo.description.should eql('')
    end

    it "sets fork" do
      repo.should_not be_fork
    end

    it "sets url" do
      repo.url.should eql('https://github.com/tsigo/hook_test')
    end

    it "sets homepage" do
      repo.homepage.should eql('')
    end

    it "sets watchers" do
      repo.watchers.should eql(1)
    end

    it "sets forks" do
      repo.forks.should eql(1)
    end
  end

  context "given data for a repository we've already seen" do
    let(:data) { payload('initial_push') }
    let(:repo) { Repository.from_payload(data) }

    it "returns the existing repository" do
      Repository.from_payload(data).should eql(repo)
    end

    it "updates the existing repository" do
      repo.update(forks: 100)
      Repository.from_payload(data)
      repo.forks.should eql(1)
    end
  end
end
