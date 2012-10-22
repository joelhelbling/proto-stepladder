require 'spec_helper'
require 'stepladder/worker'
require 'stepladder/relay_worker'

describe Stepladder::RelayWorker do
  it { should be_a(Stepladder::Worker) }

  context "with no supplier" do
    subject { Stepladder::RelayWorker.new { puts "hoo boy" } }
    it "fails on #product" do
      lambda { subject.product }.should raise_error(Stepladder::Exception, /supplier/)
    end
  end

  context "with only a supplier" do
    subject { Stepladder::RelayWorker.new(supplier) }
    let(:supplier) { double }

    it "simply passes through the supplier's value" do
      supplier.stub(:product).and_return(:foo)
      subject.product.should == :foo
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
      supplier.stub(:product).and_return("foo")
      subject.product.should == "f00"
    end
  end

  context "nil (EOF) received from supplier" do
    subject do
      Stepladder::RelayWorker.new(supplier) do |value|
        value.freak_out_over_nonexistent_method?
      end
    end
    let(:supplier) { double }

    it "passes on the nil" do
      supplier.stub(:product).and_return(nil)
      subject.product.should == nil
    end
  end
end
