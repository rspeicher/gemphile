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

  it "should be queued from an existing repository with gemspec changes" do
    pending
  end

  # Shared setup steps for #perform, #process_gemfile and #process_gemspec
  shared_examples "job setup" do
    let(:repo) { Factory(:repository, owner: 'tsigo', name: 'gemphile', url: 'https://github.com/tsigo/gemphile') }
    let(:job)  { GemfileJob.new(repo.id) }
    let(:log)  { StringIO.new }

    before do
      job.logger = Logger.new(log)
      # Set default stubs so we don't actually make HTTP requests
      job.stubs(:remote_file_exists?).returns(true)
      job.stubs(:remote_read).returns("")
    end
  end

  describe "#perform" do
    include_examples "job setup"

    it "finds the repository" do
      Repository.expects(:find).with(repo.id).returns(repo)
      job.stubs(:process_gemfile) # Speeds this up
      job.perform
    end

    it "calls process_gemfile" do
      job.expects(:process_gemfile).returns(true)
      job.perform
    end

    it "calls Repository#populate_gems with the results" do
      job.expects(:process_gemfile).returns('[]')
      Repository.any_instance.expects(:populate_gems).with('[]').returns(true)
      job.perform
    end
  end

  describe "#process_gemfile" do
    include_examples "job setup"

    context "when Gemfile exists" do
      context "with gemspec" do
        before do
          job.expects(:remote_read).returns("gemspec")
        end

        it "defers to process_gemspec" do
          job.expects(:process_gemspec).with(repo)
          job.process_gemfile(repo)
        end
      end

      context "without gemspec" do
        let(:local_file) { "#{RACK_ROOT}/tmp/#{job.object_id}.gemfile" }

        it "runs gemfile_reader, returning its output" do
          job.expects(:write_and_process).with(local_file, '').returns('reader_output')
          job.process_gemfile(repo).should eql("reader_output")
        end
      end
    end

    context "when Gemfile not found" do
      it "should raise GemfileError" do
        job.expects(:remote_file_exists?).returns(false)
        expect { job.process_gemfile(repo) }.to raise_error(GemfileJob::GemfileError, /does not exist/)
      end
    end
  end

  describe "#process_gemspec" do
    include_examples "job setup"

    context "when gemspec exists" do
      let(:local_file) { "#{RACK_ROOT}/tmp/#{job.object_id}.gemspec" }

      it "runs gemfile_reader, returning its output" do
        job.expects(:write_and_process).with(local_file, '').returns('reader_output')
        job.process_gemspec(repo).should eql("reader_output")
      end
    end

    context "when gemspec not found" do
      it "should raise GemspecError" do
        job.expects(:remote_file_exists?).returns(false)
        expect { job.process_gemspec(repo) }.to raise_error(GemfileJob::GemspecError, /does not exist/)
      end
    end
  end
end
