def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling 'syntax'
require sibling 'worker'

# This worker does not have a #receive_input method;
# it is a generator and thus "generates" values
# rather than receiving them from another Stepladder
# worker.

module Stepladder
  class Faucet < Worker
    attr_reader :injected

    def initialize(injected=nil, &block)
      @injected = injected
      @task = block

      if has_injected? && ! has_task?
        @task = lambda { |value| value }
      end
    end

    def has_injected?
      ! injected.nil?
    end

    private

    def processor(value=nil)
      validate_task

      @task.call value
    end

    def output
      if has_injected?
        process_injected
      else
        process
      end
    end

    def process_injected
      if injected
        previous_injected = injected
        @injected = process injected
        previous_injected
      end
    end

    def validate_task
      unless has_task?
        raise Exception.new(
          "You need to initialize with an injected" +
          " value or a code block, or override the processor" )
      end
    end

  end
end

