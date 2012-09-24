module Stepladder
  module Validator

    def has?(attribute)
      ! self.instance_variable_get(attribute.to_sym).nil?
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^has_(.+)\?$/
        has?($1.to_sym)
      end
    end

    private

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
