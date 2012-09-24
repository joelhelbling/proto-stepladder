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
      ! injected.nil?
    end

    private

    def processor(value=nil)
      do_validations

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

  end
end

