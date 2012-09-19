module Stepladder
  module Syntax


    def process(value=nil)
      processor value
    end

    def processor=(task)
      @task = task
    end

    def has_supplier?
      ! supplier.nil?
    end

    def has_filter?
      ! filter.nil?  
    end

    def has_task?
      ! task.nil?
    end

  end
end
