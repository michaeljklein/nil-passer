require 'test_helper'
require 'utils/self'

class SelfTest < Minitest::Test
  def test_self
    ObjectSpace.each_object do |obj|
      assert_equal obj, obj.self
    end
  end
end

