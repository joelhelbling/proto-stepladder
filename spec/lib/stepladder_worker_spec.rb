require './lib/stepladder/worker'
require './lib/stepladder/faucet'

describe Stepladder::Worker do
  it { should respond_to(:ask) }

  # will be moving this into an integration test
  describe "chain" do
    subject do
      Stepladder::Worker.new(supplier) do |message|
        message.gsub(/o/, "0")
      end
    end

    let(:supplier) do
      Stepladder::Faucet.new do
        "foo"
      end
    end

    its(:ask) { should == "f00" }
  end

  describe "pipeline" do
    subject { source_worker | subscribing_worker }
    let(:source_worker) { Stepladder::Faucet.new(1) {|v| v += 1 } }
    let(:subscribing_worker) do
      Stepladder::Worker.new do |value|
        value *= 3
      end
    end

    specify "the daisy-chain" do
      subject.ask.should == 3
      subject.ask.should == 6
      subject.ask.should == 9
    end
  end

  describe "fun with filtering" do
    subject { integers | evens }
    let(:integers) { Stepladder::Faucet.new(1) {|i| i += 1 } }
    let(:evens) do
      Stepladder::Worker.new do |number|
        number if ((number % 2) == 0)
      end
    end

    xit "returns only even numbers" do
      subject.ask.should == 2
      subject.ask.should == 4
    end
  end

end

