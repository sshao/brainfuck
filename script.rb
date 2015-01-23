require_relative "lexer"
require_relative "stages"
require "colorize"

class Brainfuck
  attr_accessor :print_bytecode

  def self.run(file, print_bytecode)
    @print_bytecode = true if print_bytecode

    bnd = Object.new
    def bnd.get; binding; end
    bnd = bnd.get

    code = File.read(file)
    meth = Compiler.compile_code(Brainfuck::Lexer.new(code).lex, bnd.variables, @print_bytecode)
    meth.scope = bnd.constant_scope
    meth.name = :__eval__

    script = Rubinius::CompiledMethod::Script.new(meth, "(eval)", true)
    script.eval_source = code

    meth.scope.script = script

    be = Rubinius::BlockEnvironment.new
    be.under_context(bnd.variables, meth)
    res = be.call

    puts "\n\nnon-zero heap values:".red
    res.each_with_index do |x, i|
      print "[#{i} => #{x}] " if x != 0
    end
    puts ""
  end
end

if ARGV.size < 1
  puts "usage: ruby script.rb <filename> <optional verbose>"
  exit
end

Brainfuck.run(ARGV.first, ARGV[1])
