require 'spec_helper'
require 'stepladder/worker'
require 'stepladder/faucet'

describe Stepladder::Faucet do
  it { should be_a(Stepladder::Worker) }

  context "with no injected value and no task" do
    subject { Stepladder::Faucet.new }
    it "fails on #product" do
      lambda{ subject.product }.should raise_error(Stepladder::Exception)
    end
  end

  context "with only an injected value" do
    subject { Stepladder::Faucet.new(:foo) }

    it "repeatedly returns the injected value" do
      subject.product.should == :foo
      subject.product.should == :foo
    end
  end

  context "with only a task (block)" do
    subject do
      Stepladder::Faucet.new do |v|
        :bar
      end
    end

    it "repeatedly returns the result of the task" do
      subject.product.should == :bar
      subject.product.should == :bar
    end
  end

  context "with both injectd value and task" do
    subject do
      Stepladder::Faucet.new(0) do |input|
        input += 2
      end
    end

    it "iterates on the injected value" do
      subject.product.should == 0
      subject.product.should == 2
      subject.product.should == 4
    end
  end

  context "overriding the processor" do
    subject { Stepladder::Faucet.new { :foo } }

    context "with instance method" do
      it "changes the worker's task" do
        subject.product.should == :foo
        def subject.processor(value)
          :bar
        end
        subject.product.should == :bar
      end
    end

    context "with #processor=" do
      it "changes the worker's task" do
        subject.product.should == :foo
        subject.processor = lambda { :bar }
        subject.product.should == :bar
      end
    end
  end

  context "when it reaches the 'end'" do
    subject do
      Stepladder::Faucet.new(2) do |value|
        value && value -= 1
        (value && value > 0) ? value : nil
      end
    end

    it "returns a nil" do
      subject.product.should == 2
      subject.product.should == 1
      subject.product.should be_nil
    end
  end

  context "when handed a supplier" do
    subject { Stepladder::Faucet.new(1) }

    it "politely declines" do
      lambda { subject.supplier = :foo }.should raise_error(Stepladder::Exception, /don't require a supplier/)
    end
  end
end
