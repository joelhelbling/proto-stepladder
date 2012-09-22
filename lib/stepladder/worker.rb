def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling('syntax')

module Stepladder
  class Worker
    attr_accessor :task

    include Stepladder::Syntax

    def initialize(source=nil, &block)
      @task = block

      create_fiber
    end

    # others may ask this guy "give me a value"
    def ask
      @my_little_machine ||= create_fiber
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
        fiber_loop
      end
    end

    # overload this as necessary for different sorts of workers
    def fiber_loop
      loop do
        Fiber.yield output
      end
    end

    # could override this method in a subclass
    def processor(value)
      @task.call value
    end

    def input
      raise "subclass & override the #input method"
    end

    def output
      process input
    end

  end

  class Exception < Exception; end
end

