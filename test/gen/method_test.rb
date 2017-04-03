require 'test_helper'
require 'gen/method'

# class DummyClass < Gen::Method
# end

class GenMethodTest < Minitest::Test
  def setup
    @dummy_class = Class.new Gen::Method
  end

  def test_def_self_1
    assert !@dummy_class.respond_to?(:example_method)
    assert !@dummy_class.new.respond_to?(:example_method)
    @dummy_class.def_self(:example_method){ true }
    assert @dummy_class.example_method
    assert @dummy_class.new.example_method
  end

  def test_def_block_gen_2
    (1..10).each do |n|
      range = (1..n).to_a
      vars  = range.map{|i| "x_#{i}"}
      @dummy_class.def_block_gen "proc_#{n}", "proc", vars.to_s.gsub(/[\[\]\"]/, '')
      defined_method = @dummy_class.method("proc_#{n}_block")
      proc_code      = vars.inspect.gsub(/\"/, '')
      assert_equal eval(defined_method.call(proc_code)).call(*range), range
    end
  end

  def test_wrap_it_3
    assert @dummy_class.wrap_it{ true }
    assert @dummy_class.new.wrap_it{ true }
    assert @dummy_class.wrap_it{ Proc.new{|x| x} }.call(true)
    assert @dummy_class.new.wrap_it{ Proc.new{|x| x} }.call(true)
  end

  def test_indent_string_4
    assert_equal @dummy_class.indent("hi"), "  hi"
    assert_equal @dummy_class.indent(['hi', 'there'].join("\n")), ['  hi', '  there'].join("\n")
  end

  def test_indent_strings_5
    assert_equal @dummy_class.indent(["hi"]), ["  hi"]
    assert_equal @dummy_class.indent([['hi', 'there'].join("\n"), 'you']), [['  hi', '  there'].join("\n"), '  you']
    assert_equal @dummy_class.indent(['hi', 'there']), ['  hi', '  there']
  end
end

