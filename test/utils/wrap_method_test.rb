require 'test_helper'
require 'utils/wrap_method.rb'

class DummyClass
  def self.a_class_method
    'a_class_method'
  end

  def an_instance_method
    'an_instance_method'
  end

  def add_singleton_method
    self.define_singleton_method :a_singleton_method, Proc.new{ 'a_singleton_method' }
  end
end


class WrapMethodTest < Minitest::Test
  def setup
    self.local_classes.length
    self.local_objects.length
  end

  def local_classes
    @@local_classes ||= ObjectSpace.each_object.select{|obj|  obj.is_a? Class}.to_a.freeze
  end

  def local_objects
    @@local_objects ||= ObjectSpace.each_object.select{|obj| !obj.is_a?(Class)}.to_a.freeze
  end

  def test_symbolic_class_methods_exist
    self.local_classes.each do |klass|
      klass.methods.each do |method_name|
        assert WrapMethod.class_method_exists?(klass, method_name), [klass, method_name].inspect
      end
    end
  end

  def test_string_class_methods_exist
    self.local_classes.each do |klass|
      klass.methods.each do |method_name|
        assert WrapMethod.class_method_exists?(klass, method_name.to_s), [klass, method_name].inspect
      end
    end
  end

  def test_symbolic_instance_methods_exist
    self.local_classes.each do |klass|
      klass.instance_methods.each do |method_name|
        assert WrapMethod.instance_method_exists?(klass, method_name), [klass, method_name].inspect
      end
    end
  end

  def test_string_instance_methods_exist
    self.local_classes.each do |klass|
      klass.instance_methods.each do |method_name|
        assert WrapMethod.instance_method_exists?(klass, method_name.to_s), [klass, method_name].inspect
      end
    end
  end

  def test_symbolic_singleton_methods_exist
    self.local_objects.each do |obj|
      obj.methods.each do |method_name|
        assert WrapMethod.singleton_method_exists?(klass, method_name), [obj, method_name].inspect
      end
    end
  end

  def test_string_singleton_methods_exist
    self.local_objects.each do |obj|
      obj.methods.each do |method_name|
        assert WrapMethod.singleton_method_exists?(klass, method_name.to_s), [obj, method_name].inspect
      end
    end
  end

  def test_oldify_all_class_methods
    self.local_classes.each do |klass|
      klass.methods.each do |method_name|
        oldified_name = WrapMethod.oldify_name method_name
        new_class = Class.new do
          define_singleton_method oldified_name, Proc.new{ true }
        end
        assert new_class.method(oldified_name).call
      end
    end
  end

  def test_oldify_all_instance_methods
    self.local_classes.each do |klass|
      klass.instance_methods.each do |method_name|
        oldified_name = WrapMethod.oldify_name method_name
        new_class = Class.new do
          define_method oldified_name, Proc.new{ true }
        end
        assert new_class.new.method(oldified_name).call
      end
    end
  end

  def test_oldify_all_singleton_methods
    self.local_objects.each do |obj|
      obj.methods.each do |method_name|
        oldified_name = WrapMethod.oldify_name method_name
        begin
          new_obj = obj.dup
          new_obj.define_singleton_method oldified_name, Proc.new{ true }
          assert new_obj.method(oldified_name).call
        rescue TypeError
        end
      end
    end
  end

  def test_class_wrap_fails_on_non_existant
    assert_nil WrapMethod.class_wrap(DummyClass, :non_existant, Proc.new{})
  end

  def test_class_wrap_fails_on_non_existant
    assert_raise ArgumentError do
      WrapMethod.class_wrap!(DummyClass, :non_existant, Proc.new{})
    end
  end

  def test_instance_wrap_fails_on_non_existant
    assert_nil WrapMethod.instance_wrap(DummyClass, :non_existant, Proc.new{})
  end

  def test_instance_wrap_fails_on_non_existant
    assert_raise ArgumentError do
      WrapMethod.instance_wrap!(DummyClass, :non_existant, Proc.new{})
    end
  end

  def test_singleton_wrap_fails_on_non_existant
    assert_nil WrapMethod.singleton_wrap(DummyClass, :non_existant, Proc.new{})
  end

  def test_singleton_wrap_fails_on_non_existant
    assert_raise ArgumentError do
      WrapMethod.singleton_wrap!(DummyClass, :non_existant, Proc.new{})
    end
  end

  def test_no_rewrap_does_not_rewrap_class
    assert_equal DummyClass.class_method, 'a_class_method'
    WrapMethod.raw_class_wrap DummyClass, :a_class_method, Proc.new{|old_method| Proc.new{'a_wrapped_class_method'}}
    assert_equal DummyClass.class_method, 'a_wrapped_class_method'
    WrapMethod.raw_class_wrap DummyClass, :a_class_method, Proc.new{|old_method| Proc.new{'a_wrapped_class_method2'}}
    assert_equal DummyClass.class_method, 'a_wrapped_class_method'
  end

  def test_no_rewrap_does_not_rewrap_instance
    assert_equal DummyClass.new.an_instance_method, 'an_instance_method'
    WrapMethod.raw_instance_wrap DummyClass, :an_instance_method, Proc.new{|old_method| Proc.new{'a_wrapped_instance_method'}}
    assert_equal DummyClass.new.an_instance_method, 'a_wrapped_instance_method'
    WrapMethod.raw_instance_wrap DummyClass, :an_instance_method, Proc.new{|old_method| Proc.new{'a_wrapped_instance_method2'}}
    assert_equal DummyClass.new.an_instance_method, 'a_wrapped_instance_method'
  end

  def test_no_rewrap_does_not_rewrap_singleton
    obj = DummyClass.new
    obj.add_singleton_method
    assert_equal obj.a_singleton_method, 'a_singleton_method'
    WrapMethod.raw_singleton_wrap obj, :a_singleton_method, Proc.new{|old_method| Proc.new{'a_wrapped_singleton_method'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
    WrapMethod.raw_singleton_wrap obj, :a_singleton_method, Proc.new{|old_method| Proc.new{'a_wrapped_singleton_method2'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
  end

  def test_rewrap_does_not_nest_on_class
    original_class_methods = DummyClass.methods
    assert_equal DummyClass.class_method, 'a_class_method'
    WrapMethod.raw_class_wrap DummyClass, :a_class_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_class_method'}}
    assert_equal DummyClass.class_method, 'a_wrapped_class_method'
    WrapMethod.raw_class_wrap DummyClass, :a_class_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_class_method2'}}
    assert_equal DummyClass.class_method, 'a_wrapped_class_method2'
    assert_equal (DummyClass.methods - original_class_methods), WrapMethod.oldify_name(:a_class_method)
  end

  def test_rewrap_does_not_nest_on_instance
    original_instance_methods = DummyClass.instance_methods
    assert_equal DummyClass.new.an_instance_method, 'an_instance_method'
    WrapMethod.raw_instance_wrap DummyClass, :an_instance_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_instance_method'}}
    assert_equal DummyClass.new.an_instance_method, 'a_wrapped_instance_method'
    WrapMethod.raw_instance_wrap DummyClass, :an_instance_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_instance_method2'}}
    assert_equal DummyClass.new.an_instance_method, 'a_wrapped_instance_method2'
    assert_equal (DummyClass.instance_methods - original_instance_methods), WrapMethod.oldify_name(:a_class_method)
  end

  def test_rewrap_does_not_nest_on_singleton
    obj = DummyClass.new
    obj.add_singleton_method
    original_singleton_methods = obj.methods
    assert_equal obj.a_singleton_method, 'a_singleton_method'
    WrapMethod.raw_singleton_wrap obj, :a_singleton_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_singleton_method'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
    WrapMethod.raw_singleton_wrap obj, :a_singleton_method, true, Proc.new{|old_method| Proc.new{'a_wrapped_singleton_method2'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method2'
    assert_equal (obj.methods - original_singleton_methods), WrapMethod.oldify_name(:a_singleton_method)
  end
end

