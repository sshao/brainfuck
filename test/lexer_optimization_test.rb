require_relative 'test_helper'

class TestLexer < MiniTest::Test
  MAPPINGS = {
    ">" => :ptr_inc,
    "<" => :ptr_dec,
    "+" => :inc,
    "-" => :dec
  }

  def test_repeat_optimizations
    num_ops = 10

    %w( > < + - ).each do |op|
      expected = [{expr: [{MAPPINGS[op] => num_ops}]}]
      assert_equal expected, Brainfuck::Lexer.new("#{op * num_ops}").lex
    end
  end
end
