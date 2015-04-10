require_relative 'test_helper'

class TestLexer < MiniTest::Test

  def test_invalid_characters
    err = assert_raises LexerError do
      Brainfuck::Lexer.new(">a>s>d>f").lex
    end
    assert_match /not a valid command/, err.message
  end

  def test_unmatched_iter_start
    err = assert_raises LexerError do
      Brainfuck::Lexer.new("[+++").lex
    end
    assert_match /missing matching brace/, err.message
  end

  def test_unmatched_iter_end
    err = assert_raises LexerError do
      Brainfuck::Lexer.new("+++]").lex
    end
    assert_match /missing matching brace/, err.message
  end

  def test_unmatched_iter_nested
    err = assert_raises LexerError do
      Brainfuck::Lexer.new("[[+]]+]").lex
    end
    assert_match /missing matching brace/, err.message
  end

  def test_strips_whitespace
    expected = [{expr: [{:ptr_inc => 2}]}]

    inputs = [" > > ", "\t>\t>\t", "\n>\n>\n"]

    inputs.each do |input|
      assert_equal expected, Brainfuck::Lexer.new(input).lex
    end
  end
end
