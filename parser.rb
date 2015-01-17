require_relative "ast"

class Brainfuck
  class Parser
    def initialize(ast)
      @ast = ast
    end

    def parse
      # FIXME oh god
      if @ast.is_a? Array
        @ast.map { |hash| generate_node(hash.keys.first) }
      else
        @ast.map { |cmd, val| generate_node(cmd, val) }
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
      #when :iteration then
      else
        "pending"
      end
    end
  end
end
