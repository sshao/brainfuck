class Brainfuck
  class Lexer
    COMMANDS = %w(> < + - . , [ ])

    def initialize(code)
      @sexp_stack = [{expr: []}]
      @code = code
    end

    def lex
      clean
      @code.each_char do |cmd|
        rule(cmd)
      end
      @sexp_stack
    end

    private
    def clean
      @code = @code.chars.select { |c| COMMANDS.include? c }.join
    end

    def rule(cmd)
      case cmd
      when ">" then @sexp_stack.last[:expr] << :ptr_inc
      when "<" then @sexp_stack.last[:expr] << :ptr_dec
      when "+" then @sexp_stack.last[:expr] << :inc
      when "-" then @sexp_stack.last[:expr] << :dec
      when "." then @sexp_stack.last[:expr] << :puts
      when "," then @sexp_stack.last[:expr] << :gets
      when "[" then
        @sexp_stack.push({expr: []})
      when "]" then
        iter = @sexp_stack.pop
        @sexp_stack.last[:expr] << {iteration: [iter]}
      else raise "#{cmd} is not a valid command"
      end
    end
  end
end
