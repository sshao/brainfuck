require_relative "lexer"
require_relative "stages"
require "colorize"

class Brainfuck
  def self.run(input, options = {})
    bnd = Object.new
    def bnd.get; binding; end
    bnd = bnd.get

    verbose = options[:verbose]
    code = File.exist?(input) ? File.read(input) : input

    meth = Compiler.compile_code(code, bnd.variables, verbose)
    meth.scope = bnd.constant_scope
    meth.name = :__eval__

    script = Rubinius::CompiledMethod::Script.new(meth, "(eval)", true)
    script.eval_source = code

    meth.scope.script = script

    be = Rubinius::BlockEnvironment.new
    be.under_context(bnd.variables, meth)
    heap = be.call

    print_heap(heap) if verbose

    heap
  end

  private
  def self.print_heap(heap)
    puts "\n\nnon-zero heap values:".red

    heap.each_with_index do |val, i|
      print "[#{i} => #{val}] " if val != 0
    end

    puts ""
  end
end

