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

      validate supplier: nil
    end

    private

    def processor(value=nil)
      do_validations
      value && @task.call(value)
    end

    def receive_input
      supplier && supplier.ask
    end

  end
end

