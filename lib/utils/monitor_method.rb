require 'utils/wrap_method'

# Example usage:
#   instance_monitor Array, :map do |map|
#     method_monitor nil, If[empty: true], If[args: 1] do |*args, &block|
#       block.call nil
#       [args, block]
#     end
#   end


class MonitorMethod < WrapMethod
  def self.new
    raise NoMethodError
  end

  # return a proc that takes a method
  # block takes |*args, &block| and returns [new_args, new_block] or falsey
  def self.method_monitor(args_predicate=nil, block_predicate=nil, &passed_block)
    unless passed_block&.parameters&.map{|x, _| x} == [:rest, :block]
      raise ArgumentError, "must pass a block with arguments of the form: |*args, &block|"
    end
    lambda do |_|
      lambda do |*args, &block|
        if !args_predicate || args_predicate.call(args)
          if !block_predicate || block_predicate.call(block)
            passed_block.call(*args, &block)
          end
        end || [args, block]
      end
    end.freeze
  end

  # return a proc that takes an unbound method
  # block takes |bound_to, *args, &block| and returns [new_args, new_block] or falsey
  def self.unbound_method_monitor(bound_predicate, args_predicate, block_predicate, &passed_block)
    unless passed_block.parameters.map{|x, _| x} == [:opt, :rest, :block]
      raise ArgumentError, "must pass a block with arguments of the form: |bound_to, *args, &block|"
    end
    lambda do |_|
      lambda do |bound_to|
        if !bound_predicate || bound_predicate.call(bound_to)
          lambda do |*args, &block|
            if !args_predicate || args_predicate.call(args)
              if !block_predicate || block_predicate.call(block)
                passed_block.call(bound_to, *args, &block)
              end
            end || [args, block]
          end
        else
          lambda do |*args, &block|
            [args, block]
          end.freeze
        end
      end
    end.freeze
  end

  class << self
    alias :class_monitor  :class_wrap
    alias :class_monitor! :class_wrap!
  end

  def self.class_monitors(klass, method_predicate=nil, &block)
    if method_predicate
      klass.public_methods.each do |method|
        if method_predicate.call klass, method
          self.class_monitor     klass, method, &block
        end
      end
    else
      klass.public_methods.each do |method|
        self.class_monitor       klass, method, &block
      end
    end
  end

  def self.classes_monitors(klass_predicate=nil, method_predicate=nil, &block)
    if klass_predicate
      ObjectSpace.each_object(Class) do |klass|
        if klass_predicate.call klass
          self.class_monitors   klass, method_predicate, &block
        end
      end
    else
      ObjectSpace.each_object(Class) do |klass|
        self.class_monitors     klass, method_predicate, &block
      end
    end
  end

  class << self
    alias :instance_monitor  :instance_wrap
    alias :instance_monitor! :instance_wrap
  end

  def self.instance_monitors(klass, method_predicate=nil, &block)
    if method_predicate
      klass.public_instance_methods.each do |method|
        if method_predicate.call klass, method
          self.instance_monitor  klass, method, &block
        end
      end
    else
      klass.public_instance_methods.each do |method|
        self.instance_monitor    klass, method, &block
      end
    end
  end

  def self.instances_monitors(klass_predicate=nil, method_predicate=nil, &block)
    if klass_predicate
      ObjectSpace.each_object(Class) do |klass|
        if klass_predicate.call  klass
          self.instance_monitors klass, method_predicate, &block
        end
      end
    else
      ObjectSpace.each_object(Class) do |klass|
        self.instance_monitors   klass, method_predicate, &block
      end
    end
  end

  class << self
    alias :singleton_monitor  :singleton_wrap
    alias :singleton_monitor! :singleton_wrap!
  end

  def self.singleton_monitors(object, method_predicate=nil, &block)
    if method_predicate
      object.public_methods.each do |method|
        if method_predicate.call object, method
          self.instance_monitor  object, method, &block
        end
      end
    else
      object.public_methods.each do |method|
        self.singleton_monitor   object, method, &block
      end
    end
  end

  def self.instances_monitors(object_predicate=nil, method_predicate=nil, &block)
    if object_predicate
      ObjectSpace.each_object(Object) do |object|
        if object_predicate.call  object
          self.singleton_monitors object, method_predicate, &block
        end
      end
    else
      ObjectSpace.each_object(Object) do |object|
        self.singleton_monitors   object, method_predicate, &block
      end
    end
  end
end

MonitorMethod.freeze

