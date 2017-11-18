require 'test_helper'
require 'gen'

class GenTest < Minitest::Test

  def trivial
    assert true
  end

  def test_gen_defined
    assert Gen.is_a?(Module)
  end

  def test_gen_code_defined
    assert Gen::Code.is_a?(Class)
  end

  def test_gen_if_defined
    assert Gen::If.is_a?(Class)
  end

  def test_gen_method_defined
    assert Gen::Method.is_a?(Class)
  end

  def test_gen_predicate_defined
    assert Gen::Predicate.is_a?(Class)
  end

end

