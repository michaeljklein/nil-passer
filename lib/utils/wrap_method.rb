
class WrapMethod
  # Convert method-only symbols into symbols acceptible for class variables
  def self.oldify_name(method_name)
    clean_method_name = method_name.to_s.gsub(/[^0-9a-zA-Z_]/) do |x|
      x.codepoints.map do |y|
        y.to_s
      end.join('_')
    end
    "@@old_#{clean_method_name}".to_sym
  end

  def self.class_method_exists?(klass, method_name)
    klass.respond_to? method_name
  end

  def self.instance_method_exists?(klass, method_name)
    klass.method_defined? method_name
  end

  class << self
    alias :singleton_method_exists? :class_method_exists?
  end

  # The block is passed the previous method (frozen).
  # `rewrap=true` means the method will be redefined (safely) if it has already been redefined.
  # Note that in redefinition, the previous wrapped definition is tossed.
  def self.raw_class_wrap(klass, method_name, rewrap=false, &block)
    old_method = nil
    if class_method_exists? klass, oldify_name(method_name)
      if rewrap
        old_method = klass.method oldify_name(method_name)
      else
        return nil
      end
    else
      old_method = klass.method(method_name).clone.freeze
      klass.define_singleton_method oldify_name(method_name), old_method
    end
    klass.define_singleton_method method_name, block.call(old_method)
  end

  def self.class_wrap(klass, method_name, &block)
    unless class_method_exists? klass, method_name
      return nil
    end
    raw_class_wrap klass, method_name, &block
  end

  def self.class_wrap!(klass, method_name, &block)
    unless class_method_exists? klass, method_name
      raise ArgumentError, "WrapMethod::class_wrap!: #{klass}::#{method_name} does not exist".freeze
    end
    self.raw_class_wrap klass, method_name, &block
  end

  # The block is passed the previous unbound method (frozen).
  # `rewrap=true` means the method will be redefined (safely) if it has already been redefined.
  #
  # Note that in redefinition, the previous wrapped definition is tossed.
  def self.raw_instance_wrap(klass, method_name, rewrap=false, &block)
    old_method = nil
    if instance_method_exists? klass, oldify_name(method_name)
      if rewrap
        old_method = klass.instance_method oldify_name(method_name)
      else
        return nil
      end
    else
      old_method = klass.instance_method(method_name).clone.freeze
      klass.send :define_method, self.oldify_name(method_name), old_method
    end
    klass.send :define_method, method_name, block.call(old_method)
  end

  # See `WrapMethod::raw_instance_wrap`.
  # This adds a check that the method exists and returns `nil` if it doesn't.
  def self.instance_wrap(klass, method_name, rewrap=false, &block)
    unless instance_method_exists? klass, method_name
      return nil
    end
    raw_instance_wrap klass, method_name, rewrap, &block
  end

  # See `WrapMethod::raw_instance_wrap`.
  # This adds a check that the method exists and raises an `ArgumentError` if it doesn't
  def self.instance_wrap!(klass, method_name, rewrap=false, &block)
    unless instance_method_exists? klass, method_name
      raise ArgumentError, "WrapMethod::instance_wrap!: #{klass}::#{method_name} does not exist".freeze
    end
    raw_instance_wrap klass, method_name, rewrap, &block
  end

  # The block is passed the previous method (frozen).
  # `rewrap=true` means the method will be redefined (safely) if it has already been redefined.
  #
  # Note that in redefinition, the previous wrapped definition is tossed.
  def self.raw_singleton_wrap(object, method_name, rewrap=false, &block)
    old_method = nil
    if singleton_method_exists? object, oldify_name(method_name)
      if rewrap
        old_method = object.method oldify_name(method_name)
      else
        return nil
      end
    else
      old_method = object.method(method_name).clone.freeze
      object.define_singleton_method oldify_name(method_name), old_method
    end
    object.define_singleton_method method_name, block.call(old_method)
  end

  # See `WrapMethod::raw_singleton_wrap`.
  # This adds a check that the method exists and returns `nil` if it doesn't.
  def self.singleton_wrap(object, method_name, rewrap=false, &block)
    unless singleton_method_exists? object, method_name
      return nil
    end
    raw_singleton_wrap object, method_name, rewrap=false, &block
  end

  # See `WrapMethod::raw_singleton_wrap`.
  # This adds a check that the method exists and raises an `ArgumentError` if it doesn't.
  def self.singleton_wrap!(object, method_name, rewrap=false, &block)
    unless singleton_method_exists? object, method_name
      raise ArgumentError, "WrapMethod::singleton_wrap!: #{object}::#{method_name} does not exist".freeze
    end
    raw_singleton_wrap object, method_name, rewrap=false, &block
  end

end

