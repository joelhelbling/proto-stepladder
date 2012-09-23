require 'spec_helper'
require 'stepladder/worker'
require 'stepladder/relay_worker'

describe Stepladder::RelayWorker do
  it { should be_a(Stepladder::Worker) }

  context "with no supplier" do
    subject { Stepladder::RelayWorker.new { puts "hoo boy" } }
    it "fails on #ask" do
      lambda { subject.ask }.should raise_error(Stepladder::Exception, /with a supplier/)
    end
  end

  context "with only a supplier" do
    subject { Stepladder::RelayWorker.new(supplier) }
    let(:supplier) { double }

    it "simply passes through the supplier's value" do
      supplier.stub(:ask).and_return(:foo)
      subject.ask.should == :foo
    end
  end

  context "with both supplier and task" do
    subject do
      Stepladder::RelayWorker.new(supplier) do |value|
        value.gsub(/o/, "0")
      end
    end
    let(:supplier) { double }

    it "operates on values passed from the supplier" do
      supplier.stub(:ask).and_return("foo")
      subject.ask.should == "f00"
    end
  end
end
