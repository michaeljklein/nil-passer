require 'test_helper'
require 'gen/method'

class DummyClass < Gen::Method
end

class GenMethodTest < Minitest::Test
  def test_def_self
    assert_not DummyClass.respond_to?(:example_method)
    assert_not DummyClass.new.respond_to?(:example_method)
    DummyClass.def_self :example_method, Proc.new{ true }
    assert DummyClass.example_method
    assert DummyClass.new.example_method
  end

  def test_def_block_gen
    (1..10).each do |n|
      range = (1..n).to_a
      vars  = range.map{|i| "x_#{i}"}
      DummyClass.def_block_gen "proc_#{n}", "proc", vars
      defined_method = DummyClass.method("proc_#{n}_block")
      proc_code      = vars.inspect.gsub(/\"/, '')
      assert_equal defined_method.call(proc_code, range), range
    end
  end

  def test_wrap_it
    assert DummyClass.wrap_it{ true }
    assert DummyClass.new.wrap_it{ true }
    assert DummyClass.wrap_it{|x| x}.call(true)
    assert DummyClass.new.wrap_it{|x| x}.call(true)
  end

  def test_indent_string
    assert_equal DummyClass.indent("hi"), "  hi"
    assert_equal DummyClass.indent(['hi', 'there'].join("\n")), ['  hi', '  there'].join("\n")
  end

  def test_indent_strings
    assert_equal DummyClass.indent(["hi"]), ["  hi"]
    assert_equal DummyClass.indent([['hi', 'there'].join("\n"), 'you']), [['  hi', '  there'].join("\n"), '  you']
    assert_equal DummyClass.indent(['hi', 'there']), ['  hi', '  there']
  end
end

