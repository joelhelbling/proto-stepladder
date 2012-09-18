
module Stepladder
  class Generator
    attr_reader :generator

    def initialize(value=nil, &block)
      @block = block
      @value = value

      # this generator fiber is meant to be a default starting point.
      @generator = Fiber.new do
        loop do
          Fiber.yield @block.call @value
        end
      end
    end

    # others may ask this guy "give me a value"
    def gimme
      @generator.resume
    end
  end
  class Function
    attr_reader :calculator, :supplier

    def initialize(parameters={}, &block)
      @block = block
      @supplier = parameters[:supplier]
      @calculator = Fiber.new do
        loop do
          Fiber.yield @block.call(@supplier.gimme)
        end
      end
    end
    def gimme
      @calculator.resume
    end
  end
end

describe Stepladder::Generator do
  subject do
    Stepladder::Generator.new do
      result
    end
  end
  let(:result) { "foo" }

  it { should respond_to(:gimme) }
  its(:gimme) { should == "foo" }
  context "when called repeatedly" do
    it "returns repeatedly" do
      subject.gimme.should == "foo"
      subject.gimme.should == "foo"
    end
  end
end

describe Stepladder::Function do
  subject do
    Stepladder::Function.new(supplier: supplier) do |input|
      input.gsub(/o/, "0")
    end
  end

  let(:supplier) do
    Stepladder::Generator.new do
      "foo"
    end
  end
  it { should respond_to(:gimme) }
  its(:gimme) { should == "f00" }
end
