class Brainfuck
  COMMANDS = %w(> < + - . , [ ])

  def initialize(input)
    @stack = Array.new(30000, 0)
    @ptr = 0
    @stream = input
    interpret
  end

  def interpret
    lookf4match = false
    lookb4match = false
    i = 0

    while i != @stream.length
      cmd = @stream[i]

      if lookf4match
        if cmd != "]"
          i += 1
          next
        end
        lookf4match = false
        i += 1
        next
      end

      if lookb4match
        if cmd != "["
          i -= 1
          next
        end
        lookb4match = false
        i += 1
        next
      end

      case cmd
      when ">" then @ptr += 1
      when "<" then @ptr -= 1
      when "+" then @stack[@ptr] += 1
      when "-" then @stack[@ptr] -= 1
      when "." then print "#{@stack[@ptr].chr}"
      # TODO when "," then
      when "[" then lookf4match = true if @stack[@ptr] == 0
      when "]" then lookb4match = true unless @stack[@ptr] == 0
      end

      i += 1
    end
  end
end

Brainfuck.new("++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.")
