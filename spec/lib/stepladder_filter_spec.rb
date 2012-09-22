require './lib/stepladder/faucet'
require './lib/stepladder/relay_worker'

module Stepladder
  class Filter < RelayWorker
    attr_accessor :filter

    def initialize(supplier=nil, regex=nil, &block)
      @supplier = supplier
      if regex && regex.is_a?(Regexp)
        @filter = lambda{ |value| !! value.to_s.match(regex) }
      else
        @filter = block
      end
    end

    private

    def fiber_loop
      validate_supplier
      validate_filter
      loop do
        while value = input
          if filter_matches? value
            Fiber.yield value
          end
        end
      end
    end

    def has_filter?
      ! filter.nil?  
    end

    def filter_matches?(value)
      filter.call value
    end

    def validate_filter
      unless has_filter?
        raise Exception.new("You need to initialize with a filter")
      end
    end

  end
end

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
end
