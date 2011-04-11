require 'spec_helper'
require 'fileutils'

describe GemfileReader, "with a simple Gemfile" do
  let(:gems) { GemfileReader.evaluate(gemfile('simplest')) }

  it "should read rails correctly" do
    gem = find_gem('rails')

    gem.name.should    eql('rails')
    gem.version.should eql('3.0.6')
    gem.path.should    be_nil
    gem.git.should     be_nil
  end

  it "should read mysql correctly" do
    gem = find_gem('mysql')

    gem.name.should    eql('mysql')
    gem.version.should be_nil
    gem.path.should    be_nil
    gem.git.should     be_nil
  end
end

describe GemfileReader, "with grouping" do
  let(:gems) { GemfileReader.evaluate(gemfile('grouping')) }

  it "should read rspec correctly" do
    gem = find_gem('rspec')

    gem.name.should    eql('rspec')
    gem.version.should eql('~> 2.5')
    gem.path.should    be_nil
    gem.git.should     be_nil
  end

  it "should read guard correctly" do
    gem = find_gem('guard')

    gem.name.should    eql('guard')
    gem.version.should be_nil
    gem.path.should    be_nil
    gem.git.should     be_nil
  end

  it "should read cucumber correctly" do
    gem = find_gem('cucumber')

    gem.name.should    eql('cucumber')
    gem.version.should eql('~> 0.10')
    gem.path.should    be_nil
    gem.git.should     be_nil
  end

  it "should read cucumber-rails correctly" do
    gem = find_gem('cucumber-rails')

    gem.name.should    eql('cucumber-rails')
    gem.version.should eql('>= 0.4')
    gem.path.should    be_nil
    gem.git.should     be_nil
  end
end
describe GemfileReader, "security spot-checks" do
  it "should not allow Ruby calls on their own" do
    gemfile = %{File.unlink("#{__FILE__}")}

    File.expects(:unlink).never
    GemfileReader.evaluate(gemfile)
  end

  context "attempting to read files" do
    it "should not allow File calls hidden after a gem call" do
      gemfile = %{gem 'foo'; File.read("/etc/hosts")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should discard tainted strings used as gem names" do
      gemfile = %{gem File.read("#{File.expand_path(__FILE__)}")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should discard tainted strings used as version strings" do
      gemfile = %{gem 'name', File.read("#{File.expand_path(__FILE__)}")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should discard tainted strings used as path strings" do
      gemfile = %{gem 'name', :path => File.read("#{File.expand_path(__FILE__)}")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should discard tainted strings used as path strings" do
      gemfile = %{gem 'name', :git => File.read("#{File.expand_path(__FILE__)}")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should disallow marking tainted strings as untainted" do
      gemfile = %{gem File.read("#{File.expand_path(__FILE__)}").untaint}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end
  end

  context "arbitrary code execution" do
    it "should not allow FileUtils.rm_rf called as argument to gem" do
      gemfile = %{gem FileUtils.rm_rf("#{__FILE__}")}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should not allow eval calls hidden after a gem call" do
      gemfile = %{gem eval(File.read("/etc/hosts"))}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should not allow backtick calls hidden after a gem call" do
      gemfile = %{gem `touch /tmp/exploited.rb`}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end

    it "should not allow %x{...} calls hidden after a gem call" do
      gemfile = %{gem %x{touch /tmp/exploited.rb}}
      expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
    end
  end
end
