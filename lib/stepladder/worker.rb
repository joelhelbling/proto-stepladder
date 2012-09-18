
module Stepladder
  class Worker

    def initialize(source=nil, &block)
      @block = block
      if source.is_a? Stepladder::Worker
        @supplier = source
      else
        @injected = source
      end

      # this generator fiber is meant to be a default starting point.
      @my_little_machine = Fiber.new do
        loop do
          Fiber.yield output
        end
      end
    end

    # others may ask this guy "give me a value"
    def ask
      @my_little_machine.resume
    end

    private

    # could override this method in a subclass --an alternative
    # to passing in a code block or an injected method
    def mutator(value)
      unless @injected || @block
        raise Exception.new("You need to initialize with an injected value or a code block, or override the mutator method!")
      end
      @block.call value
    end

    def mutate(value)
      mutator value
    end

    def output
      if @injected
        output_injected
      else
        output_standard
      end
    end

    def output_standard
      mutate input
    end

    def output_injected
      previous_value = @injected
      @injected = mutate @injected
      previous_value
    end

    def input
      @supplier.nil? ? @injected : @supplier.ask
    end

  end

  class Exception < Exception; end
end

