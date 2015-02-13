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
        subtree = s.is_a?(Hash) ? s[symbol] : []
        generate_node(symbol, subtree)
      end
    end

    private

    def generate_node(type, subtree = [])
      case type
      when :ptr_inc then AST::PointerIncrement.new
      when :ptr_dec then AST::PointerDecrement.new
      when :inc then AST::Increment.new
      when :dec then AST::Decrement.new
      when :puts then AST::Puts.new
      when :gets then AST::Gets.new
      when :expr then
        AST::Script.new(Parser.new(subtree).parse)
      when :iteration
        AST::Iteration.new(Parser.new(subtree).parse.first)
      else
        raise ParserError, "error: #{type} is not valid"
      end
    end
  end
end
