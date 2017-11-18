require 'gen/code'

module Gen
  class Predicate < Code

    # you enter a nested hash where the branches define the execution path and
    # the leaves either have a value (which will be compared with the actual
    # value) or a single-argument Proc, which is called on it.
    #
    # For example:
    #   pry(main)> make_test({:to_a=> {:length=>5}}).call (1..4)
    #   => false
    #   pry(main)> make_test({:to_a=> {:length=>5}}).call (1..5)
    #   => true
    def make_test_code(test_hash)
      input_var = local_var
      test_hash.map do |method, value|
        [new_local_var("#{input_var}.#{method}"),
        if value.is_a? Hash
          make_test_code(value)
        elsif value.is_a? Proc
          "return false unless #{bind_proc  value}.call(#{local_var})"
        else
          "return false unless #{bind_const value} ==   #{local_var} "
        end]
      end.flatten << 'return true'
    end

    # given a class, a name for the test (instance) method, and a test hash, generate a predicate
    def make_test(klass, test_name, test_hash)
      test_code = make_test_code test_hash
      test_code = proc_block test_code, 'x_0'

      arg_vars  = []
      args      = []
      @bound_procs.each_with_index do |bound_proc, index|
        arg_vars << "proc_#{index}"
        args     << bound_proc
      end
      @bound_constants.each_with_index do |bound_const, index|
        arg_vars << "const_#{index}"
        args     << bound_const
      end

      test_code = proc_block test_code, arg_vars.to_s.gsub(/[\[\]\"]/, '').freeze
      klass.class_exec do
        define_method test_name, eval(test_code).call(*args)
      end
    end

    # An alias of `#make_test`
    def self.make_test(klass, test_name, test_hash)
      self.new.make_test klass, test_name, test_hash
    end
  end
end

