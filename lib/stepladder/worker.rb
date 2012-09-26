def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling 'validator'

module Stepladder
  class Worker
    attr_accessor :task

    include Stepladder::Validator

    def initialize(source=nil, &block)
      @task = block

      create_fiber
    end

    # others may ask this guy "give me a value"
    def ask
      do_validations
      @my_little_machine ||= create_fiber
      @my_little_machine.resume
    end

    def |(subscribing_worker)
      subscribing_worker.supplier = self
      subscribing_worker
    end

    def processor=(task)
      @task = task
    end

    private

    def create_fiber
      @my_little_machine = Fiber.new do
        fiber_loop
      end
    end

    # overloadable
    def fiber_loop
      loop do
        Fiber.yield output
      end
    end

    def eof?(value)
      value.nil?
    end

    def default_task
      lambda{ |value| value }
    end

    # could override this method in a subclass
    def processor(value)
      @task.call value
    end

    def process(value=nil)
      processor value
    end

    def output
      process receive_input
    end

  end

  class Exception < Exception; end
end

