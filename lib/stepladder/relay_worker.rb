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
      lambda{|value| value }
    end

    def validate_supplier
      unless has_supplier?
        raise Exception.new("You need to initialize with a supplier")
      end
    end

    def processor(value=nil)
      validate_supplier

      @task.call value
    end

    def input
      supplier && supplier.ask
    end
  end
end

