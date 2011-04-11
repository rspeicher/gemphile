require 'spec_helper'

describe GemfileReader, "with a simple Gemfile" do
  let(:gems) { GemfileReader.evaluate(gemfile('simplest')) }

  it "should read rails correctly" do
    gem = find_gem('rails')

    gem.name.should      eql('rails')
    gem.version.should   eql('3.0.6')
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     be_nil
    gem.platform.should  be_nil
  end

  it "should read mysql correctly" do
    gem = find_gem('mysql')

    gem.name.should      eql('mysql')
    gem.version.should   be_nil
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     be_nil
    gem.platform.should  be_nil
  end
end

describe GemfileReader, "with grouping" do
  let(:gems) { GemfileReader.evaluate(gemfile('grouping')) }

  it "should read rspec correctly" do
    gem = find_gem('rspec')

    gem.name.should      eql('rspec')
    gem.version.should   eql('~> 2.5')
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     eql([:development, :test])
    gem.platform.should  be_nil
  end

  it "should read guard correctly" do
    gem = find_gem('guard')

    gem.name.should      eql('guard')
    gem.version.should   be_nil
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     eql([:test])
    gem.platform.should  be_nil
  end

  it "should read cucumber correctly" do
    gem = find_gem('cucumber')

    gem.name.should      eql('cucumber')
    gem.version.should   eql('~> 0.10')
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     eql([:test])
    gem.platform.should  be_nil
  end

  it "should read cucumber-rails correctly" do
    gem = find_gem('cucumber-rails')

    gem.name.should      eql('cucumber-rails')
    gem.version.should   eql('>= 0.4')
    gem.type.should      be_nil
    gem.path.should      be_nil
    gem.group.should     eql([:test])
    gem.platform.should  be_nil
  end
end
