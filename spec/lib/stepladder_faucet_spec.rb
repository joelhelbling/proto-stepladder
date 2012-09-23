require 'spec_helper'
require 'stepladder/worker'
require 'stepladder/faucet'

describe Stepladder::Faucet do
  it { should be_a(Stepladder::Worker) }

  context "with no injected value and no task" do
    subject { Stepladder::Faucet.new }
    it "fails on #ask" do
      lambda{ subject.ask }.should raise_error(Stepladder::Exception)
    end
  end

  context "with only an injected value" do
    subject { Stepladder::Faucet.new(:foo) }

    it "repeatedly returns the injected value" do
      subject.ask.should == :foo
      subject.ask.should == :foo
    end
  end

  context "with only a task (block)" do
    subject do
      Stepladder::Faucet.new do |v|
        :bar 
      end
    end

    it "repeatedly returns the result of the task" do
      subject.ask.should == :bar
      subject.ask.should == :bar
    end
  end

  context "with both injectd value and task" do
    subject do
      Stepladder::Faucet.new(0) do |input|
        input += 2
      end
    end

    it "iterates on the injected value" do
      subject.ask.should == 0
      subject.ask.should == 2
      subject.ask.should == 4
    end
  end

  context "overriding the processor" do
    subject { Stepladder::Faucet.new { :foo } }

    context "with instance method" do
      it "changes the worker's task" do
        subject.ask.should == :foo
        def subject.processor(value)
          :bar
        end
        subject.ask.should == :bar
      end
    end

    context "with #processor=" do
      it "changes the worker's task" do
        subject.ask.should == :foo
        subject.processor = lambda { |v| :bar }
        subject.ask.should == :bar
      end
    end
  end
end
