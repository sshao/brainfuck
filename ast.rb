class Brainfuck
  class AST
    class PointerIncrement
      def bytecode(g)
        g.push_local(1)
        g.meta_push_1
        g.meta_send_op_plus(0)
        g.set_local(1)
        g.pop
      end
    end

    class PointerDecrement
      def bytecode(g)
        g.push_local(1)
        g.meta_push_1
        g.meta_send_op_minus
        g.set_local(1)
        g.pop
      end
    end

    class Increment
      def bytecode(g)
        g.push_local(0) # get array
        g.push_local(1) # get ptr

        g.dup_many(2)   # dup array + ptr to read val at array[ptr]
        g.send(:[], 1, false) # cur = array[ptr]

        g.meta_push_1
        g.meta_send_op_plus(0) # sum = cur + 1

        g.send(:[]=, 2, false) # array[ptr] =  sum
        g.pop
      end
    end

    class Decrement
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)

        g.dup_many(2)
        g.send(:[], 1, false)

        g.meta_push_1
        g.meta_send_op_minus

        g.send(:[]=, 2, false)
        g.pop
      end
    end

    class Puts
      def bytecode(g)
        g.push_const :STDOUT
        g.push_local(0)
        g.push_local(1)
        g.send(:[], 1, false)
        g.send(:putc, 1, false)
      end
    end

    class Gets
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)
        g.send(:getc, 1, false)

        g.send(:[]=, 2, false)
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
end
