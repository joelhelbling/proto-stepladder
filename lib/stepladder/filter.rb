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
      validate supplier: nil
      validate filter: nil
    end

    private

    def fiber_loop
      loop do
        do_validations
        value = receive_input
        if eof_or_matching? value
          Fiber.yield value
        end
      end
    end

    def eof_or_matching?(value)
      value.nil? || filter_matches?(value)
    end

    def filter_matches?(value)
      filter.call value
    end

  end
end


