require_relative 'spec_helper'
require 'fileutils'

module GemfileReader
  describe GemfileReader do
    context "with a simple Gemfile" do
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

    context "with a Gemfile that uses grouping" do
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

    context "with an advanced Gemfile" do
      let(:gems) { GemfileReader.evaluate(gemfile('rails')) }

      it "should read arel correctly" do
        gem = find_gem('arel')

        gem.name.should    eql('arel')
        gem.version.should be_nil
        gem.path.should    eql('')
        gem.git.should     be_nil
      end

      it "should read RedCloth correctly" do
        gem = find_gem('RedCloth')

        gem.name.should    eql('RedCloth')
        gem.version.should eql('~> 4.2')
        gem.path.should    be_nil
        gem.git.should     be_nil
      end

      it "should read ruby-debug correctly" do
        gem = find_gem('ruby-debug')

        gem.name.should    eql('ruby-debug')
        gem.version.should eql('>= 0.10.3')
        gem.path.should    be_nil
        gem.git.should     be_nil
      end

      it "returns unique entries by name" do
        gems.select { |g| g.name == 'arel' }.length.should eql(1)
      end
    end

    context "security spot-checks" do
      it "should not allow Ruby calls on their own" do
        gemfile = %{File.unlink("/tmp/exploited.rb")}
        File.expects(:unlink).never
        GemfileReader.evaluate(gemfile)
      end

      context "attempting to read files" do
        it "should not allow File calls hidden after a gem call" do
          gemfile = %{gem 'foo'; File.read("/etc/hosts")}
          File.expects(:read).never
          GemfileReader.evaluate(gemfile)
        end

        it "should not allow File calls as the first parameter to gem" do
          gemfile = %{gem File.read("#{File.expand_path(__FILE__)}")}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end

        it "should not allow File calls as the second parameter to gem" do
          gemfile = %{gem 'name', File.read("#{File.expand_path(__FILE__)}")}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end

        it "should not allow File calls as the values of the Hash parameter to gem" do
          gemfile = %{gem 'name', :path => File.read("#{File.expand_path(__FILE__)}")}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)

          gemfile = %{gem 'name', :git => File.read("#{File.expand_path(__FILE__)}")}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end
      end

      context "arbitrary code execution" do
        it "should not allow FileUtils.rm_rf called as argument to gem" do
          gemfile = %{gem FileUtils.rm_rf("/tmp/exploited.rb")}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end

        it "should not allow eval calls hidden inside a gem call" do
          gemfile = %{gem eval(File.read("/etc/hosts"))}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end

        it "should not allow backtick calls hidden inside a gem call" do
          gemfile = %{gem `touch /tmp/exploited.rb`}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end

        it "should not allow %x{...} calls hidden inside a gem call" do
          gemfile = %{gem %x{touch /tmp/exploited.rb}}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end
      end

      context "site modification" do
        it "should not allow load path changes" do
          gemfile = %{gem $:.unshift('/tmp')}

          GemfileReader.evaluate(gemfile)
          $:.should_not include('/tmp')
        end

        it "should not allow local requires" do
          gemfile = %{gem require('spec_helper')}
          expect { GemfileReader.evaluate(gemfile) }.to raise_error(SecurityError)
        end
      end
    end
  end

  describe GemspecReader do
    context "with a simple gemspec" do
      let(:gems) { GemspecReader.evaluate(gemspec('wriggle')) }

      it "should read rspec correctly" do
        gem = find_gem('rspec')

        gem.name.should    eql('rspec')
        gem.version.should eql('~> 2.5')
      end

      it "should read yard correctly" do
        gem = find_gem('yard')

        gem.name.should    eql('yard')
        gem.version.should eql('~> 0.6')
      end
    end

    context "with a moderate gemspec" do
      let(:gems) { GemspecReader.evaluate(gemspec('shoulda')) }

      it "should read rails correctly" do
        gem = find_gem('rails')

        gem.name.should    eql('rails')
        gem.version.should eql('3.0.3')
      end

      it "should read shoulda-matchers correctly" do
        gem = find_gem('shoulda-matchers')

        gem.name.should    eql('shoulda-matchers')
        gem.version.should eql('~> 1.0.0.beta1')
      end
    end

    context "security spot-checks" do
      it "should not nest method_missing too deeply" do
        gemspec = %{s.add_dependency a.b.c.d.e 'foo', 'bar'}
        expect { GemspecReader.evaluate(gemspec) }.to raise_error(NoMethodError, /for nil/)
      end
    end
  end
end

describe GemfileReader::Entry do
  describe "#to_hash" do
    it "should convert to a Hash" do
      e = GemfileReader::Entry.new('name', 'version', 'path', 'git')
      e.to_hash.should eql({name: 'name', version: 'version', path: 'path', git: 'git'})
    end
  end
end
