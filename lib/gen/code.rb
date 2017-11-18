require 'gen/method'

module Gen
  class Gen::Code < Gen::Method
    attr_accessor :local_var_count, :bound_procs, :bound_constants

    # lambda_block: call on code and (optionally) arguments to generate a lambda
    def_block_gen :lambda

    # proc_block: call on code and (optionally) arguments to generate a proc
    def_block_gen :proc

    # local_block: call on code to keep localized during execution
    def_block_gen :local, "#{self}.wrap_it", nil

    def_block_gen :class_exec

    def initialize(local_var_count=0, bound_procs=[], bound_constants=[])
      @local_var_count = local_var_count
      @bound_procs     = bound_procs
      @bound_constants = bound_constants
    end

    # Evaluate a string using the locally bound procs and constants
    def bound_eval(source)
      self.generate_binding.eval source
    end

    # Generate a binding containing the locally bound procs and constants
    def generate_binding(a_binding=binding)
      a_binding.local_variables do |local_var|
        a_binding.local_variable_set local_var, nil
      end
      @bound_procs.zip(0..Float::INFINITY).each do |bound_proc, num|
        a_binding.local_variable_set "proc_#{num}",  bound_proc
      end
      @bound_constants.zip(0..Float::INFINITY).each do |bound_const, num|
        a_binding.local_variable_set "const_#{num}", bound_const
      end
      a_binding
    end

    # The current local variable, of form: `"x_#{@local_var_count}"`
    def local_var
      "x_#{@local_var_count}"
    end

    # Assigns a new local variable to its argument (incrementing `@local_var_count`)
    def new_local_var(other)
      @local_var_count += 1
      "#{self.local_var} = #{other}"
    end

    # Bound within `#bound_eval` as `proc_#{position in @bound_procs}`
    def bind_proc(a_proc)
      unless a_proc.is_a? Proc
        raise ArgumentError, "#{a_proc.inspect} is not a Proc, it is a #{a_proc.class}"
      end
      proc_string = "proc_#{@bound_procs.length}"
      @bound_procs     << a_proc.freeze
      proc_string
    end

    # Bound within `#bound_eval` as `const_#{position in @bound_constants}`
    def bind_const(a_const)
      const_string = "const_#{@bound_constants.length}"
      @bound_constants << a_const.freeze
      const_string
    end
  end
end


