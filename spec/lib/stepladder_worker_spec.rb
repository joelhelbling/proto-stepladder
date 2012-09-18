require './lib/stepladder/worker'

describe Stepladder::Worker do
  subject do
    Stepladder::Worker.new do
      result
    end
  end
  let(:result) { "foo" }

  it { should respond_to(:ask) }
  its(:ask) { should == "foo" }
  context "when called repeatedly" do
    it "returns repeatedly" do
      subject.ask.should == "foo"
      subject.ask.should == "foo"
    end
  end

  describe "chain" do
    subject do
      Stepladder::Worker.new(supplier) do |input|
        input.gsub(/o/, "0")
      end
    end

    let(:supplier) do
      Stepladder::Worker.new do
        "foo"
      end
    end

    its(:ask) { should == "f00" }
  end

  describe "injected" do
    subject do
      Stepladder::Worker.new(0) do |input|
        input += 2
      end
    end

    it "iterates on the injected value" do
      subject.ask.should == 0
      subject.ask.should == 2
      subject.ask.should == 4
    end
  end

  describe "override instance" do
    subject { Stepladder::Worker.new }
    it "is possible to override an instance's mutator" do
      def subject.mutator(value)
        :bar
      end
      subject.ask.should == :bar
    end
  end

  describe "error" do
    subject { Stepladder::Worker.new }
    it "needs a block, an injected value or to override the mutator method" do
      lambda{ subject.ask }.should raise_error(Stepladder::Exception)
    end
  end
end

