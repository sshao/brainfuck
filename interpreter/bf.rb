require "highline/system_extensions"

class Brainfuck
  include HighLine::SystemExtensions

  COMMANDS = %w(> < + - . , [ ])
  MEM = 30000
  PTR_BOUNDS = (0..MEM)

  def initialize(input)
    @stack = Array.new(MEM, 0)
    @ptr = 0
    @stream = input
    @ip_bounds = (0..@stream.size)

    interpret
  end

  def interpret
    ip = 0

    while ip != @stream.length
      raise "instruction pointer=#{ip} is out of bounds" unless @ip_bounds.include? ip
      raise "memory pointer=#{@ptr} is out of bounds" unless PTR_BOUNDS.include? @ptr
      cmd = @stream[ip]

      case cmd
      when ">" then @ptr += 1
      when "<" then @ptr -= 1
      when "+" then @stack[@ptr] += 1
      when "-" then @stack[@ptr] -= 1
      when "." then print "#{@stack[@ptr].chr}"
      when "," then @stack[@ptr] = get_character
      when "[" then ip = index_of_matching_brace(ip, :+) if (@stack[@ptr] == 0)
      when "]" then ip = index_of_matching_brace(ip, :-) if !(@stack[@ptr] == 0)
      else raise "command #{cmd} not in #{COMMANDS.inspect}"
      end

      ip += 1
    end
  end

  private
  def index_of_matching_brace(start, dir = :-)
    ip = start
    br_stack = []

    while @ip_bounds.include? ip
      cmd = @stream[ip]

      unless cmd == "[" or cmd == "]"
        ip = ip.send(dir, 1)
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

      ip = ip.send(dir, 1)
    end

    ip
  end
end

#Brainfuck.new(File.read("../progs/hello_world.b").strip)
#Brainfuck.new(File.read("../progs/392quine.b").strip)
Brainfuck.new(File.read("../progs/out.bf").strip)
