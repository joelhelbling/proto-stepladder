def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling('syntax')
require sibling('worker')

module Stepladder
  class Faucet < Worker
    attr_reader :injected

    def initialize(injected=nil, &block)
      @injected = injected
      @task = block

      if has_injected? && ! has_task?
        @task = lambda { |value| @injected }
      end
    end

    def has_injected?
      ! injected.nil?
    end

    private

    def validate_task
      unless has_task?
        raise Exception.new(
          "You need to initialize with an injected" +
          " value or a code block, or override the processor" )
      end
    end

    def processor(value=nil)
      validate_task

      @task.call value
    end

    def output
      if has_injected?
        previous_injected = injected
        @injected = process injected
        previous_injected
      else
        process
      end
    end

  end
end

