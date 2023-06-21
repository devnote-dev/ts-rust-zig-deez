module Monkey
  abstract class Value
    abstract def type : String
  end

  class Scope
    @store : Hash(String, Value)
    @outer : Scope?

    def initialize(@outer = nil)
      @store = {} of String => Value

      @store["len"] = BuiltinValue.new(%w[str], self) do |args|
        arg = args[0]
        if arg.is_a? StringValue
          IntegerValue.new arg.value.size
        else
          ErrorValue.new "cannot get length of type #{arg.type}"
        end
      end

      @store["rev"] = BuiltinValue.new(%w[str], self) do |args|
        arg = args[0]
        if arg.is_a? StringValue
          StringValue.new arg.value.reverse
        else
          ErrorValue.new "cannot reverse type #{arg.type}"
        end
      end
    end

    def get(key : String) : Value?
      if value = @store[key]?
        value
      elsif outer = @outer
        outer.get key
      end
    end

    def set(key : String, value : Value) : Nil
      @store[key] = value
    end
  end

  class IntegerValue < Value
    getter value : Int64

    def initialize(@value)
    end

    def type : String
      "integer"
    end
  end

  class StringValue < Value
    getter value : String

    def initialize(@value)
    end

    def type : String
      "string"
    end
  end

  class BooleanValue < Value
    getter? value : Bool

    def initialize(@value)
    end

    def type : String
      "boolean"
    end
  end

  class FunctionValue < Value
    getter parameters : Array(Identifier)
    getter body : Block
    getter scope : Scope

    def initialize(@parameters, @body, @scope)
    end

    def type : String
      "function"
    end

    def create_scope(arguments : Array(Value)) : Scope
      child = Scope.new @scope

      @parameters.each_with_index do |param, index|
        child.set param.value, arguments[index]
      end

      child
    end
  end

  class BuiltinValue < Value
    getter parameters : Array(String)
    getter scope : Scope
    @proc : Array(Value) -> Value

    def initialize(@parameters, @scope, &@proc : Array(Value) -> Value)
    end

    def call(arguments : Array(Value)) : Value
      @proc.call arguments
    end

    def create_scope(arguments : Array(Value)) : Scope
      child = Scope.new @scope

      @parameters.each_with_index do |param, index|
        child.set param, arguments[index]
      end

      child
    end

    def type : String
      "builtin function"
    end
  end

  class ReturnValue < Value
    getter value : Value

    def initialize(@value)
    end

    def type : String
      @value.type
    end
  end

  class NullValue < Value
    def type : String
      "null"
    end
  end

  class ErrorValue < Value
    getter message : String

    def initialize(@message)
    end

    def type : String
      "error"
    end
  end
end
