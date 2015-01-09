class Brainfuck
  class AST
    class PointerIncrement
      def bytecode(g)
        g.push_local(1)
        g.meta_push_1
        g.meta_send_op_plus(0)
        g.set_local(1)
      end
    end

    class PointerDecrement
      def bytecode(g)
        g.push_local(1)
        g.meta_push_1
        g.meta_send_op_minus
        g.set_local(1)
      end
    end

    class Increment
      def bytecode(g)
        g.push_local(0) # get array
        g.push_local(1) # get ptr

        g.dup_many(2)   # dup array + ptr to read val at array[ptr]
        g.send_stack(:[], 1) # cur = array[ptr]

        g.meta_push_1
        g.meta_send_op_plus(0) # sum = cur + 1

        g.send_stack(:[]=, 2) # array[ptr] =  sum
        g.pop
      end
    end

    class Decrement
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)

        g.dup_many(2)
        g.send_stack(:[], 1)

        g.meta_push_1
        g.meta_send_op_minus

        g.send_stack(:[]=, 2)
        g.pop
      end
    end

    class Puts
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)
        g.send_stack(:[], 1)
        g.send_stack(:putc, 1)
      end
    end

    class Gets
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)
        g.send_stack(:getc, 1)

        g.send_stack(:[]=, 2)
        g.pop
      end
    end

    class Script < Struct.new(:expr)
      def bytecode(g)
        expr.each do |e|
          e.bytecode(g)
        end
      end
    end
  end

  class Parser
    def initialize(ast)
      @ast = ast
    end

    def parse
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
