require 'spec_helper'
require 'stepladder/filter'
require 'stepladder/faucet'

describe Stepladder::Filter do
  it { should be_a(Stepladder::RelayWorker) }

  context "with no supplier" do
    subject { Stepladder::Filter.new { puts "hoo boy" } }
    it "fails on #ask" do
      lambda { subject.ask }.should raise_error(Stepladder::Exception, /with a supplier/)
    end
  end

  context "with no filter" do
    subject { Stepladder::Filter.new(supplier) }
    let(:supplier) { double }

    it "fails on #ask" do
      supplier.stub(:ask)
      lambda { subject.ask }.should raise_error(Stepladder::Exception, /with a filter/)
    end
  end

  context "with a regex" do
    subject { Stepladder::Filter.new(supplier, /00/) }
    let(:supplier) { Stepladder::Faucet.new(1) { |n| n += 1 } }
    context "matching input" do
      it "returns only matching values" do
        supplier.ask.should == 1
        supplier.ask.should == 2
        subject.ask.should == 100
      end
    end
  end

  context "nil (EOF) received from supplier" do
    context "with a block" do
      subject do
        Stepladder::Filter.new(supplier) do |value|
          value.freak_out_over_nonexistent_method?
        end
      end
      let(:supplier) { double }

      it "passes on the nil" do
        supplier.stub(:ask).and_return(nil)
        subject.ask.should == nil
      end
    end
    context "with a regex" do
      subject { Stepladder::Filter.new(supplier, /00/) }

      let(:supplier) { double }

      it "passes on the nil" do
        supplier.stub(:ask).and_return(nil)
        subject.ask.should == nil
      end
    end
  end
end
