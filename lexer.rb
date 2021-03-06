class LexerError < StandardError; end

class Brainfuck
  class Lexer
    def initialize(code)
      @sexp_stack = [{expr: []}]
      @code = code
    end

    def lex
      clean
      @code.each_char.with_index do |cmd, i|
        rule(cmd, i)
      end
      @sexp_stack
    end

    private
    def clean
      @code = @code.gsub(/\s+/, "")
    end

    def add(sym)
      if !@sexp_stack.last[:expr].last.nil? && @sexp_stack.last[:expr].last.keys.first == sym
        @sexp_stack.last[:expr].last[sym] += 1
      else
        @sexp_stack.last[:expr] << { sym => 1 }
      end
    end

    def rule(cmd, i)
      case cmd
      when ">" then add(:ptr_inc)
      when "<" then add(:ptr_dec)
      when "+" then add(:inc)
      when "-" then add(:dec)
      when "." then @sexp_stack.last[:expr] << {:puts => nil}
      when "," then @sexp_stack.last[:expr] << {:gets => nil}
      when "[" then
        raise LexerError, "missing matching brace" if !matching_brace?(i)
        @sexp_stack.push({expr: []})
      when "]" then
        raise LexerError, "missing matching brace" if !matching_brace?(i, :-)
        iter = @sexp_stack.pop
        @sexp_stack.last[:expr] << {iteration: [iter]}
      else
        raise LexerError, "#{cmd} is not a valid command"
      end
    end

    def within_bounds?(index)
      return index >= 0 && index < @code.length
    end

    def matching_brace?(start, dir = :+)
      br_stack = []
      cur = start
      while within_bounds?(cur)
        cmd = @code[cur]

        unless cmd == "[" or cmd == "]"
          cur = cur.send(dir, 1)
          next
        end

        if dir == :-
          br_stack.push(cmd) if cmd == "]"
          br_stack.pop if cmd == "["
        else
          br_stack.push(cmd) if cmd == "["
          br_stack.pop if cmd == "]"
        end

        break if br_stack.size == 0

        cur = cur.send(dir, 1)
      end

      return within_bounds?(cur)
    end
  end
end
