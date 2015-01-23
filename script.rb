require_relative "lexer"
require_relative "stages"

class Brainfuck
  def self.run(file)
    bnd = Object.new
    def bnd.get; binding; end
    bnd = bnd.get

    code = File.read(file)
    meth = Compiler.compile_code(Brainfuck::Lexer.new(code).lex, bnd.variables)
    meth.scope = bnd.constant_scope
    meth.name = :__eval__

    script = Rubinius::CompiledMethod::Script.new(meth, "(eval)", true)
    script.eval_source = code

    meth.scope.script = script

    be = Rubinius::BlockEnvironment.new
    be.under_context(bnd.variables, meth)
    res = be.call

    puts "\nreturn value (array):"
    res.each_with_index do |x, i|
      print "[#{i} => #{x}] " if x != 0
    end
  end
end

Brainfuck.run("../progs/print_nums.b")
