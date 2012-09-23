module Stepladder
  module Validator

    def has_supplier?
      ! @supplier.nil?
    end

    def has_task?
      ! @task.nil?
    end

    def has_injected?
      ! @injected.nil?
    end

    def has_filter?
      ! @filter.nil?
    end

    private

    def validate_supplier
      unless has_supplier?
        raise Exception.new("You need to initialize with a supplier")
      end
    end

    def validate_filter
      unless has_filter?
        raise Exception.new("You need to initialize with a filter")
      end
    end

    def validate_task
      unless has_task?
        raise Exception.new(
          "You need to initialize with an injected" +
          " value or a code block, or override the processor" )
      end
    end

    def validate(validations={})
      @validations ||= {}
      @validations.merge! validations
    end

    def do_validations
      @validations && @validations.each_pair do |attribute, label|
        unless has? attribute
          attr_name = (label && label[:as] ) || attribute
          raise Exception.new "You need to provide a #{attr_name} for this worker"
        end
      end
    end

    def has?(attribute)
      !! instance_variable_get("@#{attribute}".to_sym)
    end

  end
end
