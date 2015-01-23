require_relative "parser"

require "rubinius/compiler"
require "rubinius/ast"

class Brainfuck
  class Compiler < Rubinius::ToolSets::Runtime::Compiler
    def self.compile_code(code, variable_scope, file = "(eval)", line = 0, verbose)
      # start at stage :bf_code, end at stage :compiled_file (rubinius/compiler/stages.rb)
      compiler = new :bf_code, :compiled_file
      parser = compiler.parser

      parser.root = CodeTools::AST::EvalExpression
      parser.input code, "eval", line

      compiler.generator.variable_scope = variable_scope

      compiler.packager.print.bytecode = verbose

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

        @input.bytecode @output

        @output.close

        run_next
      end
    end

    class Code < Rubinius::ToolSets::Runtime::Compiler::Stage
      attr_accessor :root
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

      def run
        res = Brainfuck::Parser.new(@code).parse
        @output = @root.new res.first
        @output.file = @filename
        @output.pre_exe = [AST::Init::Start.new]
        run_next
      end
    end
  end
end
