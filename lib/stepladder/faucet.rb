def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

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
        @task = default_task
      end

      validate task: nil
    end

    def has_injected?
      ! @injected.nil?
    end

    def supplier=(value)
      raise Exception.new "I'm a #{self.class.name}.  I don't require a supplier.  I supply."
    end

    private

    def processor(value=nil)
      # protect against sending in nil
      if value.nil?
        @task.call
      else
        @task.call value
      end
    end

    def output
      has_injected? ? process_injected : process
    end

    def process_injected
      if injected
        previous_injected = @injected
        @injected = process @injected
        previous_injected
      end
    end

  end
end

