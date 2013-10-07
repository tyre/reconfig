require 'set'
module Reconfig
  class TypeMapper

    def stored_type(value)
      case value
      when String
        string
      when Integer
        integer
      when Float
        float
      when Hash
        hash
      when Array
        list
      when Set
        set
      else
        raise UnknownTypeException.new("Cannot map #{value.class.name}.")
      end
    end

    def string
      '1.0'
    end

    def integer
      '2.0'
    end

    def float
      '3.0'
    end

    def hash
      '4.0'
    end

    def list
      '5.0'
    end

    def set
      '6.0'
    end

  end
end

class UnknownTypeException < Exception; end