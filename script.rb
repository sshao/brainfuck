require_relative "lexer"
require_relative "stages"
require "colorize"

class Brainfuck
  def self.run(input, verbose = false)
    bnd = Object.new
    def bnd.get; binding; end
    bnd = bnd.get

    code = File.exist?(input) ? File.read(input) : input

    meth = Compiler.compile_code(code, bnd.variables, verbose)
    meth.scope = bnd.constant_scope
    meth.name = :__eval__

    script = Rubinius::CompiledMethod::Script.new(meth, "(eval)", true)
    script.eval_source = code

    meth.scope.script = script

    be = Rubinius::BlockEnvironment.new
    be.under_context(bnd.variables, meth)
    res = be.call

    if verbose
      puts "\n\nnon-zero heap values:".red

      res.each_with_index do |x, i|
        print "[#{i} => #{x}] " if x != 0
      end

      puts ""
    end

    res
  end
end

