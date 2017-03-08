require 'rails'

class NilPasser
  attr_accessor :obj, :method_name, :orig_proc
  @@rails_path   ||= Rails.root.to_s
  @@rails_logger ||= Rails.logger

  def self.test(a_caller, block)
    if (block&.arity == 1) && a_caller.first&.start_with?(@@rails_path)
      begin
        block.call nil
      rescue Exception => e
        @@rails_logger.tagged("no-nil") { @@rails_logger.info "found a block that can't handle nil at #{block.source_location}, error: #{e.inspect}" }
      end
    end
  end

  def self.clone(klass, method_name)
    begin
      # ensure that the method is not recursively redefined
      klass.class_variable_get("@@old_#{method_name}".to_sym)
    rescue NameError
      klass.instance_method(method_name).clone
    end
  end

  def self.teardown(nil_passers)
    nil_passers.each do |nil_passer|
      nil_passer.teardown
    end
  end

  def initialize(obj, method_name=nil, accepts_args=true)
    if obj.is_a? Class
      self.initialize_class    obj, method_name, accepts_args
    else
      self.initialize_instance obj, method_name, accepts_args
    end
  end

  # stuff -> @@old_stuff
  def to_old(x)
    # need to convert method-only symbols into symbols acceptible for class variables
    clean_x = x.to_s.gsub(/[^0-9a-zA-Z_]/) do |y|
      y.codepoints.map do |z|
        z.to_s
      end.join('_')
    end
    "@@old_#{clean_x}".to_sym
  end

  def initialize_class(klass, method_name=nil, accepts_args=true)
    if method_name
      obj.class.class_variable_set(to_old method_name, NilPasser.clone(obj, method_name))
      if accepts_args
        # I don't know how to send this to klass without eval
        eval [ "class #{klass}",
               "  def #{method_name}(*args, &block)",
               "    NilPasser.test caller, block",
               "    #{to_old method_name}.bind(self)&.call(*args, &block)",
               "  end",
               "end"
        ].join("\n")
      else
        eval [ "class #{klass}",
               "  def #{method_name}(&block)",
               "    NilPasser.test caller, block",
               "    #{to_old method_name}.bind(self)&.call(&block)",
               "  end",
               "end"
        ].join("\n")
      end
    else
      obj.methods.map do |method|
        NilPasser.new(obj, method)
      end
    end
  end

  def initialize_instance(inst, method_name=nil, accepts_args=true)
    if method_name
      begin
        @obj         = inst
        @method_name = method_name
        @orig_proc   = inst.method(method_name).to_proc
      rescue NameError => e
        raise ArgumentError, "The provided method must be a valid method of the provided object, got: #{e}"
      end
    else
      (inst.methods - Object.methods).map do |method|
        NilPasser.new(obj, method)
      end
    end
  end

  def setup
    @orig_proc = self.obj.method(@method_name).to_proc.clone
    @obj.send(:define_singleton_method, @method_name, self.method(:call).to_proc)
    self
  end

  def call(*args, &block)
    NilPasser.test caller, block
    @orig_proc.call(*args, &block)
  end

  def teardown
    @obj.send(:define_singleton_method, @method_name, @orig_proc)
  end
end

# def generate_nil_passers(klass, methods, no_arg_methods=[])
#   methods = methods.select do |method|
#     begin
#       klass.instance_method method
#       true
#     rescue NameError
#       false
#     end
#   end

#   no_arg_methods = no_arg_methods.select do |method|
#     begin
#       klass.instance_method method
#       true
#     rescue NameError
#       false
#     end
#   end

#   old_decls = (methods + no_arg_methods).map do |method|
#     "@@old_#{sane method} = NilPasser.clone #{klass}, :#{method}"
#   end.map{|str| "  " + str}

#   new_decls = methods.map do |method|
#     [ "def #{method}(*args, &block)",
#       "  NilPasser.test caller, block",
#       "  @@old_#{sane method}.bind(self)&.call(*args, &block)",
#       "end"
#     ].map{|str| "  " + str}
#   end

#   new_no_arg_decls = no_arg_methods.map do |method|
#     [ "def #{method}(&block)",
#       "  NilPasser.test caller, block",
#       "  @@old_#{sane method}.bind(self)&.call(&block)",
#       "end"
#     ].map{|str| "  " + str}
#   end

#   [ "class #{klass}",
#     old_decls,
#     new_decls,
#     new_no_arg_decls,
#     "end"
#   ].flatten.join("\n")
# end

# def generate_all_nil_passers(klass)
#   generate_nil_passers klass, (klass.methods - klass.superclass.methods).select{|x| x.to_s.present?}
# end

# eval generate_all_nil_passers(ActiveRecord::Relation)
# eval generate_all_nil_passers(Hash)
# eval generate_all_nil_passers(Enumerator)
# eval generate_all_nil_passers(Array)
# eval generate_all_nil_passers(String)


# eval generate_nil_passers(ActiveRecord::Relation, [:select, :find_each], [:each])
# eval generate_nil_passers(Hash,                   [],                    [:each_key, :each_value])
# eval generate_nil_passers(Enumerator,             [],                    [:each])
# eval generate_nil_passers(Array,                  [:collect, :select],   [:each, :map])
# eval generate_nil_passers(String,                 [:each_line])

# puts "**** loaded nil passer *********"


