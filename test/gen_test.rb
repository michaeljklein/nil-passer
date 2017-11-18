require 'test_helper'
require 'gen'

class GenTest < Minitest::Test

  def trivial
    assert true
  end

  def test_gen_defined
    assert Gen.is_a?(Module)
  end

end


