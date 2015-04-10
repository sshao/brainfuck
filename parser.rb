require_relative "ast"

class ParserError < StandardError; end

class Brainfuck
  class Parser
    def initialize(ast)
      @ast = ast
    end

    def parse
      # FIXME still not good
      @ast.map do |s|
        symbol = s.is_a?(Hash) ? s.keys.first : s
        args = s.is_a?(Hash) ? s[symbol] : []
        generate_node(symbol, args)
      end
    end

    private

    def generate_node(type, args = [])
      case type
      when :ptr_inc then AST::PointerIncrement.new(args)
      when :ptr_dec then AST::PointerDecrement.new(args)
      when :inc then AST::Increment.new(args)
      when :dec then AST::Decrement.new(args)
      when :puts then AST::Puts.new
      when :gets then AST::Gets.new
      when :expr then
        AST::Script.new(Parser.new(args).parse)
      when :iteration
        AST::Iteration.new(Parser.new(args).parse.first)
      else
        raise ParserError, "error: #{type} is not valid"
      end
    end
  end
end
