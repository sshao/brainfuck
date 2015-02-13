require_relative "brainfuck"
require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "usage: ruby bf_compile.rb <filename/code> [verbose]"

  opts.on("-v", "--verbose", "Run verbosely") do
    options[:verbose] = true
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end

  if ARGV.size < 1
    puts opts
    exit
  end
end.parse!

Brainfuck.run(ARGV.first, options)
