require 'test_helper'
require 'gen/code'

class GenCodeTest < Minitest::Test
  def setup
    @code_gen = Gen::Code.new
  end

  def test_lambda_block_1
    lambda_code = @code_gen.lambda_block("x", "x")
    a_lambda    = @code_gen.bound_eval lambda_code
    assert a_lambda.is_a?(Proc)
    assert a_lambda.lambda?
    assert a_lambda.call(true)
  end

  def test_proc_block_2
    proc_code = @code_gen.proc_block("x", "x")
    a_proc    = @code_gen.bound_eval proc_code
    assert a_proc.is_a?(Proc)
    assert a_proc.call(true)
  end

  def test_local_block_3
    x = true
    block_code = @code_gen.local_block(["x = false", "true"])
    a_block    = @code_gen.bound_eval block_code
    assert a_block
    assert x
  end

  def test_chaining_local_vars_4
    chained_code = (1..10).map do |n|
      prev_local_var = @code_gen.local_var
      @code_gen.new_local_var prev_local_var
    end
    chained_code << @code_gen.local_var
    chained_proc = @code_gen.proc_block(chained_code, 'x_0')
    assert_equal @code_gen.bound_eval(chained_proc).call(123), 123
  end

  def test_bind_proc_5
    proc_var  = @code_gen.bind_proc Proc.new{ true }
    proc_code = @code_gen.proc_block proc_var
    assert @code_gen.bound_eval(proc_code).call
  end

  def test_bind_const_6
    const_var = @code_gen.bind_const true
    proc_code = @code_gen.proc_block const_var
    assert @code_gen.bound_eval(proc_code).call
  end
end

