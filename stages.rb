require_relative "parser"

require "rubinius/compiler"
require "rubinius/ast"

class Brainfuck
  class Compiler < Rubinius::ToolSets::Runtime::Compiler
    def self.compile_code(code, variable_scope, file = "(eval)", verbose)
      compiler = new :bf_code, :compiled_file
      parser = compiler.parser

      parser.root = CodeTools::AST::EvalExpression
      parser.input code, "eval", 1

      compiler.generator.variable_scope = variable_scope

      compiler.packager.print.bytecode = verbose if verbose

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
        @code = Brainfuck::Lexer.new(code).lex
        @filename = filename
        @line = line
      end

      def run
        ast = Brainfuck::Parser.new(@code).parse
        @output = @root.new ast.first
        @output.file = @filename
        @output.pre_exe = [AST::Init::Start.new]
        run_next
      end
    end
  end
end
