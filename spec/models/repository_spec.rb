require 'spec_helper'

describe Repository do
  describe ".from_payload" do
    context "given invalid or private data" do
      it "ignores Hash data" do
        Repository.from_payload(foo: 'bar').should be_nil
      end

      it "rescues from a JSON parse error" do
        expect { Repository.from_payload('') }.to_not raise_error
      end

      it "ignores payloads without repository info" do
        payload = %{{"name": "repo"}}
        expect { Repository.from_payload(payload) }.to_not change(Repository, :count)
      end

      it "ignores private repositories" do
        expect { Repository.from_payload(github('private_repo')) }.to_not change(Repository, :count)
      end
    end

    context "given valid data" do
      let(:repo) { Repository.from_payload(github('initial_push')) }

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
      let(:data) { github('initial_push') }
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

  describe "#populate_gems" do
    let(:repo) { Factory(:repository) }

    context "given valid data" do
      it "populates gem records" do
        gemstr = gemfile('simplest')

        expect { repo.populate_gems(gemstr) }.to change(repo.gems, :count).from(0).to(2)
      end

      it "removes old gem records before adding new ones" do
        # Add "old" gems
        repo.populate_gems(gemfile('simplest'))

        repo.populate_gems(gemfile('grouping'))
        repo.gems.any? { |g| g.name == 'rails' }.should be_false
        repo.gems.any? { |g| g.name == 'cucumber' }.should be_true
      end

      it "updates GemCount after create" do
        3.times do
          repo = Factory(:repository)
          repo.gems.create(name: 'gemphile')
        end

        GemCount.find('gemphile').count.should eql(3)
      end

      it "updates GemCount after destroy" do
        3.times do
          repo = Factory(:repository)
          repo.gems.create(name: 'gemphile')
        end

        # FIXME: This is the only way to get this test to pass
        # - Repository.last.destroy fails because it doesn't cascade the callback to its embedded docs
        # - Repository.last.gems.destroy_all fails because... I don't know
        Repository.last.gems.each(&:destroy)
        GemCount.find('gemphile').count.should eql(2)
      end
    end

    context "given empty data" do
      it "does not raise an error" do
        expect { repo.populate_gems('[]') }.to_not raise_error
      end
    end
  end
end
