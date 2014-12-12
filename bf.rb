require "highline/system_extensions"

class Brainfuck
  include HighLine::SystemExtensions

  COMMANDS = %w(> < + - . , [ ])
  BOUNDS = (0..30000)

  def initialize(input)
    @stack = Array.new(30000, 0)
    @br_stack = []
    @ptr = 0
    @stream = input
    interpret
  end

  def interpret
    lookf4match = false
    lookb4match = false
    i = 0

    while i != @stream.length
      raise "index=#{i} is out of bounds" unless (0..@stream.length).include? i
      raise "@ptr=#{@ptr} is out of bounds" unless BOUNDS.include? @ptr
      cmd = @stream[i]

      if lookf4match
        unless cmd == "[" or cmd == "]"
          i += 1
          next
        end

        @br_stack.push(cmd) if cmd == "["
        @br_stack.pop if cmd == "]"

        if @br_stack.size == 0
          lookf4match = false
          i += 1
          next
        else
          i += 1
          next
        end
      elsif lookb4match
        unless cmd == "[" or cmd == "]"
          i -= 1
          next
        end

        @br_stack.push(cmd) if cmd == "]"
        @br_stack.pop if cmd == "["

        if @br_stack.size == 0
          lookb4match = false
          i += 1
          next
        else
          i -= 1
          next
        end
      end

      case cmd
      when ">" then @ptr += 1
      when "<" then @ptr -= 1
      when "+" then @stack[@ptr] += 1
      when "-" then @stack[@ptr] -= 1
      when "." then print "#{@stack[@ptr].chr}"
      when "," then @stack[@ptr] = get_character
      when "[" then
        if @stack[@ptr] == 0
          lookf4match = true
          @br_stack.push(cmd)
        end
      when "]" then
        unless @stack[@ptr] == 0
          lookb4match = true
          i -= 1
          @br_stack.push(cmd)
        end
      else
        raise
      end

      i += 1 unless lookb4match
    end
  end
end

Brainfuck.new(File.read("../progs/hello_world.b").strip)
Brainfuck.new(File.read("../progs/392quine.b").strip)
