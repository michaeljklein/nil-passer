# require 'rails'
# require_relative 'predicate_gen'
# require_relative 'code_gen'
# require_relative 'self'



# class NiceOptions
#   # here, we reformat a few options to match the format of MethodTester

#     # if options[:arguments]
#     #   arity
#     #   count
#     #   argument_tests
#     #   arguments_test
#     #   :_0 => proc or value
#     #   :_1 => proc or value
#     #   has_defaults
#     # end

#     # if options[:block]
#     #   block_options = options[:block]
#     #   self.add_prerequisite_from_proc_or_equal [:block], Proc, block_options[:is]
#     #   self.add_prerequisite_from_proc_or_equal [:block, :arity], Fixnum, block_options[:arity]
#     #   self.add_prerequisite_from_proc_or_equal [:block, :binding], Binding, block_options[:binding]
#     #   self.add_prerequisite_from_proc_or_equal [:block, :hash], Fixnum, block_options[:hash]
#     #   self.add_prerequisite_from_proc_or_equal [:block, :lambda], Proc, block_options[:lambda]
#     #   self.add_prerequisite_from_proc_or_equal [:block, :source_location], Pathname, block_options[:source_location]
#     #   parameters
#     # end

#     # if options[:in]
#     #   if options[:in].is_a?(Proc) && options[:in].arity == 1
#     #     # add proc(source_location) as prerequisite
#     #     self.add_prerequisite :source_location, options[:in]
#     #   elsif options[:in].is_a? Pathname
#     #     if options[:in].extname == ".rb"
#     #       self.add_prerequisite :source_location, Proc.new{|source_location| source_location == options[:in]}
#     #     else
#     #       self.add_prerequisite :source_location, Proc.new{|source_location| source_location.start_with?(options[:in])}
#     #     end
#     #   elsif options[:in].is_a? String
#     #     options[:in] = Pathname.new options[:in]
#     #     if options[:in].extname == ".rb"
#     #       self.add_prerequisite :source_location, Proc.new{|source_location| source_location == options[:in]}
#     #     else
#     #       self.add_prerequisite :source_location, Proc.new{|source_location| source_location.start_with?(options[:in])}
#     #     end
#     #   else
#     #     raise ArgumentError, "options[:in]: Expected a single-argument Proc or a Pathname/String of a directory/source file location, got: #{options[:in]}"
#     #   end
#     # end

#     # if options[:called_on]
#     #   if options[:called_on].is_a? Proc
#     #     # add proc(called_on) as prerequisite
#     #   else
#     #     # add called_on == value as a prerequisite
#     #   end
#     # end
#   # end


#   # assume applies to all class/instance variables of given symbol (when called like MethodMonitor.monitor Klass, :sym)
#   # default monitors do nothing
#   # only adds the features used to the method (so probably have to generate source to remain fast)
#   # only: (0..1) adds the monitor with percent probability
#   # only: Fixnum adds only Fixnum monitors
# end


# class MethodMonitor
#   def self.test(a_caller, block)
#     if (block&.arity == 1) && a_caller.first&.start_with?(@@rails_path)
#       begin
#         block.call nil
#       rescue Exception => e
#         @@rails_logger.tagged("no-nil") { @@rails_logger.info "found a block that can't handle nil at #{block.source_location}, error: #{e.inspect}" }
#       end
#     end
#   end

#   def self.clone(klass, method_name)
#     begin
#       # ensure that the method is not recursively redefined
#       klass.class_variable_get("@@old_#{method_name}".to_sym)
#     rescue NameError
#       klass.instance_method(method_name).clone
#     end
#   end

#   # stuff -> @@old_stuff
#   def to_old(x)
#     # need to convert method-only symbols into symbols acceptible for class variables
#     clean_x = x.to_s.gsub(/[^0-9a-zA-Z_]/) do |y|
#       y.codepoints.map do |z|
#         z.to_s
#       end.join('_')
#     end
#     "@@old_#{clean_x}".to_sym
#   end


#   def initialize_instance(inst, method_name=nil, accepts_args=true)
#     if method_name
#       begin
#         @obj         = inst
#         @method_name = method_name
#         @orig_proc   = inst.method(method_name).to_proc
#       rescue NameError => e
#         raise ArgumentError, "The provided method must be a valid method of the provided object, got: #{e}"
#       end
#     else
#       (inst.methods - Object.methods).map do |method|
#         NilPasser.new(obj, method)
#       end
#     end
#   end

#   def call(*args, &block)
#     NilPasser.test caller, block
#     @orig_proc.call(*args, &block)
#   end

#   def teardown
#     @obj.send(:define_singleton_method, @method_name, @orig_proc)
#   end

#   def sanitize_options(options)
#     clean_options = {}
#     [:arguments_given, :block_given, :in, :has_defaults, :called_on].each do |symbol|
#       clean_options[symbol] = options[symbol]
#     end
#     clean_options
#   end

#   # at the _where_ point, call predicate and only continue if it returns a truthy value
#   def add_prerequisite_from_proc_or_equal(where, klass, predicate)
#   end

#   def singleton_method(*args, &block)
#     def self.test_singleton_method
#     end
#   end

#   def instance_method(*args, &block)
#     def self.test_instance_method
#     end
#   end

#   def class_method(*args, &block)
#     def self.test_class_method
#     end
#   end

#   def monitor_singleton_method(object, method_name=nil, accepts_args=true)
#   end

#   def monitor_instance_method(klass, method_name=nil, accepts_args=true)
#     if method_name
#       obj.class.class_variable_set(to_old method_name, self.clone(obj, method_name))
#       if accepts_args
#         # I don't know how to send this to klass without eval
#         eval [ "class #{klass}",
#                "  def #{method_name}(*args, &block)",
#                "    #{self.class}.test_instance_method caller, block",
#                "    #{to_old method_name}.bind(self)&.call(*args, &block)",
#                "  end",
#                "end"
#         ].join("\n")
#       else
#         eval [ "class #{klass}",
#                "  def #{method_name}(&block)",
#                "    #{self.class}.test_instance_method caller, block",
#                "    #{to_old method_name}.bind(self)&.call(&block)",
#                "  end",
#                "end"
#         ].join("\n")
#       end
#     else
#       klass.instance_methods.each{|method| self.monitor_instance_method method}
#     end
#   end

#   def monitor_class_method(klass, method_name=nil, accepts_args=true)
#     if method_name
#       obj.class.class_variable_set(to_old(method_name, :class), self.clone(obj, method_name))
#       if accepts_args
#         # I don't know how to send this to klass without eval
#         eval [ "class self.#{klass}",
#                "  def #{method_name}(*args, &block)",
#                "    #{self.class}.test_instance_method caller, block",
#                "    #{to_old method_name}.bind(self)&.call(*args, &block)",
#                "  end",
#                "end"
#         ].join("\n")
#       else
#         eval [ "class self.#{klass}",
#                "  def #{method_name}(&block)",
#                "    #{self.class}.test_instance_method caller, block",
#                "    #{to_old method_name}.bind(self)&.call(&block)",
#                "  end",
#                "end"
#         ].join("\n")
#       end
#     else
#       klass.instance_methods.each{|method| self.monitor_instance_method method}
#     end
#   end

#   def monitor(object, method_name=nil)
#     if object.is_a?(Class)
#       self.monitor_instance_method  object, method_name
#       self.monitor_class_method     object, method_name
#     else
#       self.monitor_singleton_method object, method_name
#     end
#   end
# end




# # class NilPasser < MethodMonitor
# #   @@rails_path ||= Rails.root.to_s

# #   # instance_method block_given: { arity: 1 }, in: Rails.root, only: 0.5 do |method, args, block|
# #   instance_method block_given: { arity: 1, in: Rails.root } do |method, args, block|
# #     begin
# #       block.call nil
# #     rescue Exception => e
# #       puts "found block at #{block.source_location}, error: #{e.inspect}"
# #     end
# #   end
# # end

# # Array.monitor

# # Array.monitor(:map)

# # NilPasser.monitor Array, :map
# # NilPasser.monitor Array
# # NilPasser.monitor Array.method


# class NilPasser
#   attr_accessor :obj, :method_name, :orig_proc
#   @@rails_path   ||= Rails.root.to_s
#   @@rails_logger ||= Rails.logger

#   def self.test(a_caller, block)
#     if (block&.arity == 1) && a_caller.first&.start_with?(@@rails_path)
#       begin
#         block.call nil
#       rescue Exception => e
#         @@rails_logger.tagged("no-nil") { @@rails_logger.info "found a block that can't handle nil at #{block.source_location}, error: #{e.inspect}" }
#       end
#     end
#   end

#   def self.clone(klass, method_name)
#     begin
#       # ensure that the method is not recursively redefined
#       klass.class_variable_get("@@old_#{method_name}".to_sym)
#     rescue NameError
#       klass.instance_method(method_name).clone
#     end
#   end

#   def self.teardown(nil_passers)
#     nil_passers.each do |nil_passer|
#       nil_passer.teardown
#     end
#   end

#   def initialize(obj, method_name=nil, accepts_args=true)
#     if obj.is_a? Class
#       self.initialize_class    obj, method_name, accepts_args
#     else
#       self.initialize_instance obj, method_name, accepts_args
#     end
#   end

#   # stuff -> @@old_stuff
#   def to_old(x)
#     # need to convert method-only symbols into symbols acceptible for class variables
#     clean_x = x.to_s.gsub(/[^0-9a-zA-Z_]/) do |y|
#       y.codepoints.map do |z|
#         z.to_s
#       end.join('_')
#     end
#     "@@old_#{clean_x}".to_sym
#   end

#   def initialize_class(klass, method_name=nil, accepts_args=true)
#     if method_name
#       obj.class.class_variable_set(to_old method_name, NilPasser.clone(obj, method_name))
#       if accepts_args
#         # I don't know how to send this to klass without eval
#         eval [ "class #{klass}",
#                "  def #{method_name}(*args, &block)",
#                "    NilPasser.test caller, block",
#                "    #{to_old method_name}.bind(self)&.call(*args, &block)",
#                "  end",
#                "end"
#         ].join("\n")
#       else
#         eval [ "class #{klass}",
#                "  def #{method_name}(&block)",
#                "    NilPasser.test caller, block",
#                "    #{to_old method_name}.bind(self)&.call(&block)",
#                "  end",
#                "end"
#         ].join("\n")
#       end
#     else
#       obj.methods.map do |method|
#         NilPasser.new(obj, method)
#       end
#     end
#   end

#   def initialize_instance(inst, method_name=nil, accepts_args=true)
#     if method_name
#       begin
#         @obj         = inst
#         @method_name = method_name
#         @orig_proc   = inst.method(method_name).to_proc
#       rescue NameError => e
#         raise ArgumentError, "The provided method must be a valid method of the provided object, got: #{e}"
#       end
#     else
#       (inst.methods - Object.methods).map do |method|
#         NilPasser.new(obj, method)
#       end
#     end
#   end

#   def setup
#     @orig_proc = self.obj.method(@method_name).to_proc.clone
#     @obj.send(:define_singleton_method, @method_name, self.method(:call).to_proc)
#     self
#   end

#   def call(*args, &block)
#     NilPasser.test caller, block
#     @orig_proc.call(*args, &block)
#   end

#   def teardown
#     @obj.send(:define_singleton_method, @method_name, @orig_proc)
#   end
# end

