require_relative "parser"

require "rubinius/compiler"
require "rubinius/ast"

class Brainfuck
  class Compiler < Rubinius::ToolSets::Runtime::Compiler
    def self.compile_code(code, variable_scope, file = "(eval)", line = 0)
      compiler = new :bf_code, :compiled_method
      parser = compiler.parser

      parser.root CodeTools::AST::EvalExpression
      parser.input code, "eval", line

      compiler.generator.variable_scope = variable_scope

      compiler.packager.print.bytecode = true

      code = compiler.run

      code.add_metadata :for_eval, true
      return code
    end
  end

  module Stages
    class Generator < Rubinius::ToolSets::Runtime::Compiler::Stage
      attr_accessor :variable_scope
      next_stage Rubinius::ToolSets::Runtime::Compiler::Encoder

      def initialize(compiler, last)
        super
        compiler.generator = self
      end

      def run
        @output = Rubinius::ToolSets::Runtime::Generator.new

        @output.set_line Integer(1)
        @output.local_count = 2
        @output.local_names = ["arr", "ip"]

        @output.meta_push_0
        @output.set_local 1
        @output.push_const :Array
        @output.push_int(30_000)
        @output.meta_push_0
        @output.send(:new, 2)
        @output.cast_array
        @output.set_local 0

        @input.first.bytecode @output

        @output.push_local 0
        @output.ret

        @output.close

        run_next
      end
    end

    class Code < Rubinius::ToolSets::Runtime::Compiler::Stage
      stage :bf_code
      next_stage Generator

      def initialize(compiler, last)
        super
        compiler.parser = self
      end

      def input(code, filename = "eval", line = 1)
        @code = code
        @filename = filename
        @line = line
      end

      def root(klass)
        @root = klass
      end

      def run
        @output = Brainfuck::Parser.new(@code).parse
        run_next
      end
    end
  end
end
