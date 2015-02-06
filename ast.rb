require "rubinius/compiler"
require "rubinius/ast"

module CodeTools
  module AST
    # Override EvalExpression#bytecode so
    # that it returns the heap at the end
    class EvalExpression < Container
      def bytecode(g)
        super(g)

        container_bytecode(g) do
          @body.bytecode(g)
          g.push_local 0
          g.ret
        end
      end
    end
  end
end

class Brainfuck
  class AST
    class Init
      class InitHeap
        def initialize
          @size = 30_000
          @default = 0
        end

        def bytecode(g)
          args = [CodeTools::AST::FixnumLiteral.new(1, @size),
                  CodeTools::AST::FixnumLiteral.new(1, @default)]
          receiver = CodeTools::AST::ConstantAccess.new(1, :Array)

          CodeTools::AST::SendFastNew.new(1, receiver, :new, CodeTools::AST::ArrayLiteral.new(1, args)).bytecode(g)
        end
      end

      class InitPtr
        def bytecode(g)
          CodeTools::AST::FixnumLiteral.new(1,0).bytecode(g)
        end
      end

      class Start
        def pre_bytecode(g)
          g.set_line Integer(1)
          CodeTools::AST::LocalVariableAssignment.new(1, :array, InitHeap.new).bytecode(g)
          g.set_local 0
          CodeTools::AST::LocalVariableAssignment.new(1, :ptr, InitPtr.new).bytecode(g)
          g.set_local 1
        end
      end
    end

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
        g.meta_send_op_minus(0)
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
        g.meta_send_op_minus(0)

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
        g.pop
      end
    end

    class Gets
      def bytecode(g)
        g.push_local(0)
        g.push_local(1)

        g.push_const :STDIN
        g.send(:getc, 0, false)

        g.send(:[]=, 2, false)

        g.pop
      end
    end

    class Iteration
      def initialize(body)
        @body = body
      end

      def bytecode(g)
        start = g.new_label
        start.set!

        @body.bytecode(g)
        g.push_local 0
        g.push_local 1
        g.send(:[], 1, false)
        g.meta_push_0
        g.meta_send_op_equal(0)
        g.gif start
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
