def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling('syntax')

module Stepladder
  class Worker
    attr_accessor :supplier, :task

    include Stepladder::Syntax

    def initialize(source=nil, &block)
      # This is nasty.  Go polymorphic: the programmer knows
      # what the purpose of the worker is when she creates it.
      if source.is_a? Stepladder::Worker
        @supplier = source
      elsif source.is_a? Regexp
        @filter = source
      end

      @task = block

      create_fiber
    end

    # others may ask this guy "give me a value"
    def ask
      @my_little_machine.resume
    end

    def tell(message)
      # not implemented yet...will interact with a dispatcher
    end

    def |(subscribing_worker)
      subscribing_worker.supplier = self
      subscribing_worker
    end

    private

    def create_fiber
      @my_little_machine = Fiber.new do
        loop do
          Fiber.yield output
        end
      end
    end

    # could override this method in a subclass
    def processor(value)
      @task.call value
    end

    def input
      supplier.ask
    end

    def output
      process input
    end

  end

  class Exception < Exception; end
end

