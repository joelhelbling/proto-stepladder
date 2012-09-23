def sibling(file)
  File.join(File.dirname(__FILE__), file)
end

require sibling 'relay_worker'

module Stepladder
  class Filter < RelayWorker
    attr_accessor :filter

    def initialize(supplier=nil, regex=nil, &block)
      @supplier = supplier
      if regex && regex.is_a?(Regexp)
        @filter = lambda{ |value| !! value.to_s.match(regex) }
      else
        @filter = block
      end
    end

    private

    def fiber_loop
      validate_supplier
      validate_filter
      loop do
        while value = input
          if filter_matches? value
            Fiber.yield value
          end
        end
      end
    end

    def has_filter?
      ! filter.nil?
    end

    def filter_matches?(value)
      filter.call value
    end

    def validate_filter
      unless has_filter?
        raise Exception.new("You need to initialize with a filter")
      end
    end

  end
end


