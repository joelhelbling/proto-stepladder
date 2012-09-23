def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling 'worker'

module Stepladder
  class RelayWorker < Worker
    attr_accessor :supplier

    def initialize(supplier=nil, &block)
      @supplier = supplier
      @task = block || default_task
    end

    private

    def default_task
      lambda{ |value| value }
    end

    # handle EOF
    def processor(value=nil)
      validate_supplier
      value && @task.call(value)
    end

    def receive_input
      supplier && supplier.ask
    end

  end
end

