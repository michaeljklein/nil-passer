# require 'rails'
# require_relative 'predicate_gen'
# require_relative 'code_gen'
# require_relative 'self'

# class Gen::MonitorArgs
#   attr_accessor :block_given, :in, :only
# end

# class Gen::MonitorOptions
#   # recurse the options, replacing convenient options with pedantic ones
#   def recurse(options)
#     if options.is_a? Hash
#       options.map do |k, v|
#         k2, v2 = if self.respond_to? "options_#{k}"
#           self.send("options_#{k}", v) || [k, v]
#         end
#         v2 ||= self.recurse v2
#         [k2, v2]
#       end.to_h
#     end
#   end

#   def options_in(x)
#     if x
#       if x.is_a?(Proc) && x.arity == 1
#         # add proc(source_location) as prerequisite
#         [:source_location, x]
#       elsif x.is_a? Pathname
#         if x.extname == ".rb"
#           [:source_location, Proc.new{|source_location| source_location == x}]
#         else
#           [:source_location, Proc.new{|source_location| source_location.start_with?(x)}]
#         end
#       elsif x.is_a? String
#         x = Pathname.new x
#         if x.extname == ".rb"
#           [:source_location, Proc.new{|source_location| source_location == x}]
#         else
#           [:source_location, Proc.new{|source_location| source_location.start_with?(x)}]
#         end
#       else
#         raise ArgumentError, "Gen::MonitorOptions#in: Expected a single-argument Proc, a Pathname/String of a directory/source file location, or a list of those, got: #{x}"
#       end
#     end
#   end

#   def options_arguments(x)
#     if x.is_a? Hash
#       x.map do |k, v|
#         if /_(?<num>\d+)/ =~ k
#           if v.is_a? Proc
#             [k, Proc.new{|y| v.call(y[num.to_i])}]
#           else
#             [k, Proc.new{|y| v ==   y[num.to_i] }]
#           end
#         elsif "has_defaults" == k.to_s && [false, true].include?(v)
#           [k, Proc.new{|y| y.parameters.map{|z, _| z}.any?{|w| w == :opt} == v}]
#         else
#           [k, v]
#         end
#       end
#     end
#   end

#   def options_only(x)
#     if x.respond_to? :to_f
#       Proc.new{ rand <= x.to_f }
#     end
#   end
# end

# # idea is that if predicate, pass args to a Proc and continue on. used for logging, tests, etc.
# class Gen::Monitor < Gen::Code
#   def self.nice_options(options={})
#     options
#   end

#   def self.class_method(options={}, &block)
#   end

#   def self.instance_method(options={}, &block)
#     arguments_test = make_arguments_test (options[:arguments] || options[:args])
#     block_test     = make_block_test     options[:block_given]
#     in_test        = make_in_test        options[:in]
#     method_test    = make_method_test    options[:method]
#     only_test      = make_only_test      options[:only]
#     Proc.new do |method, *args, &block|
#       in
#       method
#       block
#       arguments
#       only
#     end
#   end
# end


# class NilPasser < MethodMonitor
#   @@rails_path ||= Rails.root.to_s

#   # instance_method block_given: { arity: 1 }, in: Rails.root, only: 0.5 do |method, args, block|
#   instance_method block_given: { arity: 1, in: Rails.root } do |method, args, block|
#     begin
#       block.call nil
#     rescue Exception => e
#       puts "found block at #{block.source_location}, error: #{e.inspect}"
#     end
#   end
# end




# class NiceOptions
#   # here, we reformat a few options to match the format of MethodTester

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

