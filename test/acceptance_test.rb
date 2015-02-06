require_relative 'test_helper'

class TestBrainfuck < MiniTest::Test

  def test_ok
    assert_evaluates [2,1], "++++>++++---.<--."
  end

  def test_without_loops_nor_user_input
    code = "++++>++++---.<--."

    STDOUT.expects(:putc).times(2)
    assert_evaluates [2,1], code

    expected = StringIO.new
    expected.putc(1)
    expected.putc(2)

    out, _ = capture_subprocess_io do
      assert_evaluates [2,1], code
    end

    assert_includes(out, expected.string)
  end

  def test_with_user_input
    STDIN.expects(:getc).returns 97

    assert_evaluates [101], ",++++"
  end

  def test_with_loops
    assert_evaluates [1], "++++[-]+-+"
  end

  def test_transfers_from_one_cell_to_another
    assert_evaluates [0, 10], "++++++++++      [>+<-]"
  end

  def test_transfers_from_one_cell_to_the_third
    assert_evaluates [0, 0, 10], "++++++++++      [>+<-]>[>+<-]"
  end

  def test_transfers_from_one_cell_to_the_third_and_back_to_the_second
    assert_evaluates [0, 10, 0], "++++++++++      [>+<-]>[>+<-]>[<+>-]"
  end

  def test_nested_loop_examples
    assert_evaluates [0], "[++++++++++[-]+-+-]"
  end

  def test_hello_world
    code = <<-EOS
      +++++ +++++            
      [                      
          > +++++ ++         
          > +++++ +++++      
          > +++              
          > +                
          <<<< -              
      ]                   
      > ++ .                  
      > + .                   
      +++++ ++ .              
      .                       
      +++ .                   
      > ++ .                  
      << +++++ +++++ +++++ .  
      > .                     
      +++ .                   
      ----- - .               
      ----- --- .             
      > + .                   
      > .                     
  EOS

    out, _ = capture_subprocess_io do
      assert_evaluates [0, 87, 100, 33, 10], code
    end

    assert_equal(out, "Hello World!\n")
  end

  private

  def assert_evaluates(expected, code)
    expected = expected + Array.new(30000-expected.size, 0)

    assert_equal expected, Brainfuck.run(code, nil)
  end
end
