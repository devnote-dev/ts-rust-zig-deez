require "spec"
require "../src/*"

include Monkey

def parse(input : String) : Array(Statement)
  tokens = Lexer.new(input).run
  program = Parser.new(tokens).parse

  program.statements
end

def eval(input : String) : Monkey::Value
  tokens = Lexer.new(input).run
  program = Parser.new(tokens).parse
  result = Evaluator.evaluate program, Scope.new

  result
end
