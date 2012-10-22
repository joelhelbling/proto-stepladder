require 'spec_helper'
require 'stepladder/worker'
require 'stepladder/faucet'
require 'stepladder/filter'
require 'stepladder/relay_worker'

describe Stepladder::Worker do
  it { should respond_to(:product) }

  describe "pipeline" do
    subject { source_worker | subscribing_worker }
    let(:source_worker) { Stepladder::Faucet.new(1) {|v| v += 1 } }
    let(:subscribing_worker) do
      Stepladder::RelayWorker.new do |value|
        value *= 3
      end
    end

    specify "the daisy-chain" do
      subject.product.should == 3
      subject.product.should == 6
      subject.product.should == 9
    end
  end

  describe "fun with filtering" do
    subject { integers | evens }
    let(:integers) { Stepladder::Faucet.new(1) {|i| i += 1 } }
    let(:evens) do
      Stepladder::Filter.new do |number|
        number if ((number % 2) == 0)
      end
    end

    it "returns only even numbers" do
      subject.product.should == 2
      subject.product.should == 4
    end
  end

end

