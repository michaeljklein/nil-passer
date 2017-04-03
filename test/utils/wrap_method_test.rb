require 'test_helper'
require 'utils/wrap_method.rb'

class WrapMethodTest < Minitest::Test
  def setup
    @dummy_class = Class.new do
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
    self.local_classes.length
    self.local_objects.length
  end

  def local_classes
    @@local_classes ||= ObjectSpace.each_object.select{|obj|  obj.is_a? Class}.to_a.freeze
  end

  def local_objects
    @@local_objects ||= ObjectSpace.each_object.select{|obj| !obj.is_a?(Class) && !obj.is_a?(Module)}.to_a.freeze
  end

  def test_symbolic_class_methods_exist_1
    self.local_classes.each do |klass|
      klass.methods.each do |method_name|
        assert WrapMethod.class_method_exists?(klass, method_name), [klass, method_name].inspect
      end
    end
  end

  def test_string_class_methods_exist_2
    self.local_classes.each do |klass|
      klass.methods.each do |method_name|
        assert WrapMethod.class_method_exists?(klass, method_name.to_s), [klass, method_name].inspect
      end
    end
  end

  def test_symbolic_instance_methods_exist_3
    self.local_classes.each do |klass|
      klass.instance_methods.each do |method_name|
        assert_equal WrapMethod.instance_method_exists?(klass, method_name), klass.method_defined?(method_name), [klass, method_name]
      end
    end
  end

  def test_string_instance_methods_exist_4
    self.local_classes.each do |klass|
      klass.instance_methods.each do |method_name|
        assert_equal WrapMethod.instance_method_exists?(klass, method_name.to_s), klass.method_defined?(method_name), [klass, method_name]
      end
    end
  end

  def test_symbolic_singleton_methods_exist_5
    # This is somewhat of a misnomer. This is meant to check a variety of names for consistency, not exhaustively check all methods.
    # The exhaustive check is great, but too slow so we require that the method names be unique to speed it up.
    known_methods = {}
    self.local_objects.each do |obj|
      obj.public_methods.select{|method| known_methods[method].nil?}.each do |method_name|
        known_methods[method_name] = true
        assert_equal WrapMethod.singleton_method_exists?(obj, method_name), obj.respond_to?(method_name), [obj, method_name].inspect
      end
    end
  end

  def test_string_singleton_methods_exist_6
    # This is somewhat of a misnomer. This is meant to check a variety of names for consistency, not exhaustively check all methods.
    # The exhaustive check is great, but too slow so we require that the method names be unique to speed it up.
    known_methods = {}
    self.local_objects.each do |obj|
      obj.public_methods.select{|method| known_methods[method].nil?}.each do |method_name|
        known_methods[method_name] = true
        assert_equal WrapMethod.singleton_method_exists?(obj, method_name.to_s), obj.respond_to?(method_name), [obj, method_name].inspect
      end
    end
  end

  def test_oldify_all_class_methods_7
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

  def test_oldify_all_instance_methods_8
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

  def test_oldify_all_singleton_methods_9
    self.local_objects.select do |obj|
      !obj.frozen?
      end.each do |obj|
      obj.methods.each do |method_name|
        oldified_name = WrapMethod.oldify_name method_name
        begin
          obj.define_singleton_method oldified_name, Proc.new{ true }
          assert obj.method(oldified_name).call
        rescue TypeError
        end
      end
    end
  end

  def test_class_wrap_fails_on_non_existant_10
    assert_nil WrapMethod.class_wrap(@dummy_class, :non_existant){}
  end

  def test_class_wrap_fails_on_non_existant_11!
    assert_raises ArgumentError do
      WrapMethod.class_wrap!(@dummy_class, :non_existant){}
    end
  end

  def test_instance_wrap_fails_on_non_existant_12
    assert_nil WrapMethod.instance_wrap(@dummy_class, :non_existant){}
  end

  def test_instance_wrap_fails_on_non_existant_13!
    assert_raises ArgumentError do
      WrapMethod.instance_wrap!(@dummy_class, :non_existant){}
    end
  end

  def test_singleton_wrap_fails_on_non_existant_14
    assert_nil WrapMethod.singleton_wrap(@dummy_class, :non_existant){}
  end

  def test_singleton_wrap_fails_on_non_existant_15!
    assert_raises ArgumentError do
      WrapMethod.singleton_wrap!(@dummy_class, :non_existant){}
    end
  end

  def test_no_rewrap_does_not_rewrap_class_16
    assert_equal @dummy_class.a_class_method, 'a_class_method'
    WrapMethod.raw_class_wrap(@dummy_class, :a_class_method){|old_method| Proc.new{'a_wrapped_class_method'}}
    assert_equal @dummy_class.a_class_method, 'a_wrapped_class_method'
    WrapMethod.raw_class_wrap(@dummy_class, :a_class_method){|old_method| Proc.new{'a_wrapped_class_method2'}}
    assert_equal @dummy_class.a_class_method, 'a_wrapped_class_method'
  end

  def test_no_rewrap_does_not_rewrap_instance_17
    assert_equal @dummy_class.new.an_instance_method, 'an_instance_method'
    WrapMethod.raw_instance_wrap(@dummy_class, :an_instance_method){|old_method| Proc.new{'a_wrapped_instance_method'}}
    assert_equal @dummy_class.new.an_instance_method, 'a_wrapped_instance_method'
    WrapMethod.raw_instance_wrap(@dummy_class, :an_instance_method){|old_method| Proc.new{'a_wrapped_instance_method2'}}
    assert_equal @dummy_class.new.an_instance_method, 'a_wrapped_instance_method'
  end

  def test_no_rewrap_does_not_rewrap_singleton_18
    obj = @dummy_class.new
    obj.add_singleton_method
    assert_equal obj.a_singleton_method, 'a_singleton_method'
    WrapMethod.raw_singleton_wrap(obj, :a_singleton_method){|old_method| Proc.new{'a_wrapped_singleton_method'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
    WrapMethod.raw_singleton_wrap(obj, :a_singleton_method){|old_method| Proc.new{'a_wrapped_singleton_method2'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
  end

  def test_rewrap_does_not_nest_on_class_19
    original_class_methods = @dummy_class.methods
    assert_equal @dummy_class.a_class_method, 'a_class_method'
    WrapMethod.raw_class_wrap(@dummy_class, :a_class_method, true){|old_method| Proc.new{'a_wrapped_class_method'}}
    assert_equal @dummy_class.a_class_method, 'a_wrapped_class_method'
    WrapMethod.raw_class_wrap(@dummy_class, :a_class_method, true){|old_method| Proc.new{'a_wrapped_class_method2'}}
    assert_equal @dummy_class.a_class_method, 'a_wrapped_class_method2'
    assert_equal (@dummy_class.methods - original_class_methods), [WrapMethod.oldify_name(:a_class_method)]
  end

  def test_rewrap_does_not_nest_on_instance_20
    original_instance_methods = @dummy_class.instance_methods
    assert_equal @dummy_class.new.an_instance_method, 'an_instance_method'
    WrapMethod.raw_instance_wrap(@dummy_class, :an_instance_method, true){|old_method| Proc.new{'a_wrapped_instance_method'}}
    assert_equal @dummy_class.new.an_instance_method, 'a_wrapped_instance_method'
    WrapMethod.raw_instance_wrap(@dummy_class, :an_instance_method, true){|old_method| Proc.new{'a_wrapped_instance_method2'}}
    assert_equal @dummy_class.new.an_instance_method, 'a_wrapped_instance_method2'
    assert_equal (@dummy_class.instance_methods - original_instance_methods), [WrapMethod.oldify_name(:an_instance_method)]
  end

  def test_rewrap_does_not_nest_on_singleton_21
    obj = @dummy_class.new
    obj.add_singleton_method
    original_singleton_methods = obj.methods
    assert_equal obj.a_singleton_method, 'a_singleton_method'
    WrapMethod.raw_singleton_wrap(obj, :a_singleton_method, true){|old_method| Proc.new{'a_wrapped_singleton_method'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method'
    WrapMethod.raw_singleton_wrap(obj, :a_singleton_method, true){|old_method| Proc.new{'a_wrapped_singleton_method2'}}
    assert_equal obj.a_singleton_method, 'a_wrapped_singleton_method2'
    assert_equal (obj.methods - original_singleton_methods), [WrapMethod.oldify_name(:a_singleton_method)]
  end
end

