module RcovStats
  class ErbBinding

    def initialize( options )
      options.each_pair do |key, value|
        instance_variable_set(:"@#{key}",value)
      end
    end

    def get_binding
      binding
    end
  end
end
