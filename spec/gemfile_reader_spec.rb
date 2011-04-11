require 'spec_helper'

describe GemfileReader, "with a simple Gemfile" do
  let(:gems) { GemfileReader.evaluate(gemfile('simplest')) }

  describe "first entry" do
    subject { gems[0] }

    its(:name) { should eql('rails') }
    its(:version) { should eql('3.0.6') }
    its(:type) { should be_nil }
    its(:path) { should be_nil }
    its(:group) { should be_nil }
    its(:platform) { should be_nil }
  end

  describe "second entry" do
    subject { gems[1] }

    its(:name) { should eql('mysql') }
    its(:version) { should be_nil }
    its(:type) { should be_nil }
    its(:path) { should be_nil }
    its(:group) { should be_nil }
    its(:platform) { should be_nil }
  end
end
